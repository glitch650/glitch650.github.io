// GLITCH650 SECURITY - Real Web Crypto, No Fake Locks
// AES-256-GCM via Web Crypto API. Keys never leave this device. No secrets in code.
const SEC = {
  async deriveKey(password, salt){
    const enc = new TextEncoder();
    const base = await crypto.subtle.importKey('raw', enc.encode(password), 'PBKDF2', false, ['deriveKey']);
    return crypto.subtle.deriveKey({name:'PBKDF2', salt, iterations: 600000, hash:'SHA-256'}, base, {name:'AES-GCM', length:256}, false, ['encrypt','decrypt']);
  },
  async encrypt(plain, password){
    const salt = crypto.getRandomValues(new Uint8Array(16));
    const nonce = crypto.getRandomValues(new Uint8Array(12)); // NEVER reused - fresh every time
    const key = await this.deriveKey(password, salt);
    const ct = await crypto.subtle.encrypt({name:'AES-GCM', iv: nonce}, key, new TextEncoder().encode(plain));
    const out = new Uint8Array(salt.length + nonce.length + ct.byteLength);
    out.set(salt,0); out.set(nonce,16); out.set(new Uint8Array(ct),28);
    return btoa(String.fromCharCode(...out));
  },
  async decrypt(b64, password){
    const data = Uint8Array.from(atob(b64), c=>c.charCodeAt(0));
    const salt = data.slice(0,16), nonce = data.slice(16,28), ct = data.slice(28);
    const key = await this.deriveKey(password, salt);
    const pt = await crypto.subtle.decrypt({name:'AES-GCM', iv: nonce}, key, ct);
    return new TextDecoder().decode(pt);
  },
  // TOTP MFA - RFC 6238, real time-based code
  async totp(secret, timeStep=30){
    const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(secret), {name:'HMAC', hash:'SHA-1'}, false, ['sign']);
    const counter = Math.floor(Date.now()/1000/timeStep);
    const buf = new ArrayBuffer(8); new DataView(buf).setBigUint64(0, BigInt(counter));
    const sig = new Uint8Array(await crypto.subtle.sign('HMAC', key, buf));
    const off = sig[63] & 0xf;
    const code = ((sig[off]&0x7f)<<24|(sig[off+1]<<16)|(sig[off+2]<<8|sig[off+3]) % 1000000;
    return String(code).padStart(6,'0');
  },
  audit(action, detail){
    // NEVER log passwords, keys, tokens, decrypted data
    const safe = String(detail||'').replace(/password|token|key|secret/gi,'[REDACTED]');
    const log = JSON.parse(localStorage.getItem('g650_audit')||'[]');
    log.unshift({t:new Date().toISOString(), action, detail:safe, ua:navigator.userAgent.slice(0,60)});
    localStorage.setItem('g650_audit', JSON.stringify(log.slice(0,200)));
    this.renderAudit();
  },
  renderAudit(){
    const el = document.getElementById('auditList'); if(!el) return;
    const log = JSON.parse(localStorage.getItem('g650_audit')||'[]');
    el.innerHTML = log.length ? log.map(l=>`<div style="padding:10px 0;border-bottom:1px solid #292929;font-size:13px"><b style="color:#D4AF37">${l.action}</b> <span style="color:#A6A6A6">${new Date(l.t).toLocaleString()}</span><br><span style="color:#A6A6A6">${l.detail}</span></div>`).join('') : '<p style="color:#A6A6A6">No events yet.</p>';
  }
};

// Session + Inactivity Logout + Re-auth for critical actions
let lastActivity = Date.now();
['click','keydown','touchstart'].forEach(e=>document.addEventListener(e, ()=>{ lastActivity=Date.now(); }, {passive:true}));
setInterval(()=>{
  const sess = JSON.parse(localStorage.getItem('g650_session')||'null');
  if(sess && Date.now()-lastActivity > 15*60*1000){
    localStorage.removeItem('g650_session');
    SEC.audit('AUTO_LOGOUT','Inactivity 15 min');
    alert('Logged out for inactivity (15 min). Please login again.');
    location.reload();
  }
  const el=document.getElementById('sessionInfo'); if(el && sess) el.textContent='Active session • '+new Date(sess.loginAt).toLocaleString()+' • '+sess.device;
}, 30000);

function requireReauth(action, fn){
  const lastAuth = Number(localStorage.getItem('g650_last_auth')||0);
  if(Date.now()-lastAuth > 5*60*1000){
    const pw = prompt('Re-authentication required for: '+action+'\nEnter admin password:');
    if(!pw) return;
    // Verify against stored hash (SHA-256 of password + salt, never plaintext)
    const stored = JSON.parse(localStorage.getItem('g650_admin_hash')||'null');
    if(!stored){ alert('No admin password set. Set it in Security Center first.'); return; }
    crypto.subtle.digest('SHA-256', new TextEncoder().encode(stored.salt+pw)).then(h=>{
      const hex=[...new Uint8Array(h)].map(b=>b.toString(16).padStart(2,'0')).join('');
      if(hex===stored.hash){ localStorage.setItem('g650_last_auth', Date.now()); SEC.audit('REAUTH_OK', action); fn(); }
      else { SEC.audit('REAUTH_FAIL', action); alert('Wrong password.'); }
    });
    return;
  }
  fn();
}
