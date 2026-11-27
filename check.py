import requests
# read key from visits.py automatically
text = open('visits.py').read()
key = text.split('API_KEY = "')[1].split('"')[0]
bin_id = text.split('BIN_ID = "')[1].split('"')[0]
print("BIN:", bin_id)
print("KEY starts:", key[:10])
r = requests.get(f"https://api.jsonbin.io/v3/b/{bin_id}/latest", headers={"X-Master-Key": key}, timeout=15)
print("Status:", r.status_code)
print("Reply:", r.text[:500])
