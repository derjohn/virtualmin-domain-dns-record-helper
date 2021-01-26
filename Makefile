DOMAINID ?=
ENDPOINT ?=
VUSER ?=
VPASS ?=
RECORDTTL ?=
RECORDTYPE ?= A
RECORDNAME ?=
RECORDVALUE ?=
RECORDCOMMENT ?= virtualmin-domain-dns-record-helper
TMPFILE ?= ./sessionauth
NAMESERVER ?= @8.8.8.8 # Set this to you own virtualmin nameserver address to see updates faster / avoid DNS caching

default: help
.SILENT: # don't expose password on shell

sessionauth: ## Fetch Session & Authenticate
	curl -s -c $(TMPFILE) -b testing=1 --data-urlencode user=$(VUSER) --data-urlencode pass=$(VPASS) '$(ENDPOINT)/session_login.cgi' -o /dev/null

saverecord: ## RECORDTYPE={A,TXT,CNAME} RECORDNAME=<recordname or key> RECORDVALUE=<value, e.g. 127.0.0.1> [RECORDTTL=<value in seconds>]
	curl -b $(TMPFILE) '$(ENDPOINT)/virtual-server/save_record.cgi' -G \
	--data-urlencode dom=$(DOMID) \
	--data-urlencode type=$(RECORDTYPE) \
	--data-urlencode name_def=0 \
	--data-urlencode name=$(RECORDNAME) \
	--data-urlencode ttl_def=1 \
	--data-urlencode ttl= $(RECORDTTL) \
	--data-urlencode ttl_units=s \
	--data-urlencode value_0=$(RECORDVALUE) \
	--data-urlencode comment=$(RECORDCOMMENT)

deleterecord: ## RECORDTYPE={A,TXT,CNAME} RECORDNAME=<recordname FQDN style with dot at the end> RECORDVALUE=<value, e.g. 127.0.0.1>
	curl -b $(TMPFILE) '$(ENDPOINT)/virtual-server/delete_records.cgi' -G \
	--data-urlencode dom=$(DOMID) \
	--data-urlencode d=$(RECORDNAME)/$(RECORDTYPE)/$(RECORDVALUE) \
	--data-urlencode type=$(RECORDTYPE) \
	--data-urlencode delete=delme

fetchrecordvalue: ## RECORDTYPE={A,TXT,CNAME} RECORDNAME=<recordname FQDN style with dot at the end>
	dig +short -t $(RECORDTYPE) $(NAMESERVER) $(RECORDNAME)

clean: ## Removes the session auth file
	rm $(TMPFILE)

help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

