# Log Venom - The log poisoner (beta)
## !!==> Poison all of their logs <==!!
Shell script with capabilities to poison logs with XSS (more attacks coming soon)

# Installation
- Install cURL
    - `sudo apt-get install curl`
- Install Wget
    - `sudo apt-get install wget`
- Install waybackurls
    - Get a pre-built binary from [here](https://github.com/tomnomnom/waybackurls/releases) according to your system
    - Move it to `/usr/bin/` with command `sudo mv waybackurls /usr/bin`

# Template
The template should be in the `yaml` format with 1 empty line (whitespace) at last
## Template options
- `url`: The target url (mandatory)
- `attacks`: Attacks to perform (currently XSS supported)
- `xssht`: Your username of [XSS Hunter](https://xsshunter.com)
- `wayback`: Search for URLs on waybackmachine to poison them (all subdomains would be poisoned)
- `poison`: Severity of attacks

### Poison Levels
- Low
    - Poison in User-Agent field
    - Use GET and POST methods to POISON
- Medium
    - Features of low poison level +
    - Inject in URL
    - Try to cause error so that it would be logged
        - Inject payload in request method
- High
    - Features of medium poison level +
    - Inject in well known HTTP headers

# Examples
Example of template for low impact
```yaml
url: http://localhost
attacks: xss
xssht: username
wayback: false
poison: low

```

Example of template for medium impact
```yaml
url: http://localhost
attacks: xss
xssht: username
wayback: true
poison: medium

```
Example of template for high impact
```yaml
url: http://localhost
attacks: xss
xssht: username
wayback: true
poison: high

```

# Payload fires
You will be notified on [XSS Hunter](https://xsshunter.com) whenever any of the XSS payload fires
