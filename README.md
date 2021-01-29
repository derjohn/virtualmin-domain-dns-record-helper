# virtualmin-domain-dns-record-helper
Update DNS Records via http(s) without having master user API access. A virtual server admin account is sufficient to perform DNS record updates. So if you just booked a virtual server from some hosting provider that uses virtualmin and you want shell access to your DNS records (e.g. for letsencrypt DNS challenge integration), then this helper if for you.

## Requirements
* curl
* make
* dig
* (optional) direnv

## Setup
Export all variables you need to access the virtualmin GUI as env vars:

```
export DOMID=1234567890
export ENDPOINT=https://virtualmin.example.com
export VUSER=hostingdomain.example
export VPASS=verysecret
```

You can use direnv package to automate this. You can put those exports in a .envrc file. See envrc.sample.
The DOMID is the ID of the domain, you can see that number in the GUI panel "virtual server summary" or you can fetch it from the URL in virtualmin.

## Example usage
```
make clean
make sessionauth
make saverecord RECORDTYPE=A RECORDNAME=example RECORDVALUE=127.0.0.1
make saverecord RECORDTYPE=TXT RECORDNAME=example RECORDVALUE=schooschoo
make saverecord RECORDTYPE=A RECORDNAME=example RECORDVALUE=127.0.0.1 DOMID=987654321
make deleterecord RECORDTYPE=A RECORDVALUE=127.0.0.2 RECORDNAME=delme.example.com. # Yes, this needs to be the full name with dot.
make fetchrecordvalue RECORDNAME=delme.exeample.com.
make deleterecord RECORDNAME=delme.example.com. RECORDTYPE=A RECORDVALUE=127.0.0.2 # Type A record is default
```

## Using with curl-only
If you comment out the .SILENT target in the Makefile, you can see the rendered curl commands when executing make an steal the output for your own scripting.

