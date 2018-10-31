# Constraints
GREP_OPTIONS="--exclude={project.assets.json,*.csproj} --exclude-dir={bin,obj}"
sensitiveWords="pass\|token\|secret\|key\|auth\|connection\|affiliation"
sensitiveHttpComponents="HttpClient\|IHttpClient\|HttpClientFactory"
sensitiveSQLComponents="DbContext\|SqlConnection\|SqlCommand\|SqlDataReader"
sensitiveSerializationsComponents="Serialization\|XmlSerializer\|ISerializable"
sensitiveAuthenticationComponents="JWT\|Bearer\|AddAuthentication\|Claim"
language=CSharp
projectName="$(echo $1 | cut -d "/" -f5)"
reportPath=../$projectName.html

function appendReportLine {
    echo $1 >> $reportPath
}

function startReportCreation {
    >| $reportPath
    appendReportLine "<html>"
    appendReportLine "<head>"
    appendReportLine "<link rel=\"stylesheet\" href=\"libs/styles/jquery-ui.css\">"
    appendReportLine "<script src=\"libs/javascript/jquery-1.12.4.js\"></script>"
    appendReportLine "<script src=\"libs/javascript/jquery-ui.js\"></script>"
    appendReportLine "<script src=\"libs/javascript/main.js\"></script>"
    appendReportLine "</head>"
    appendReportLine "<body>"
    appendReportLine "<h1 align=\"center\">Code Scan Report: $projectName</h1>"
    appendReportLine "<div id=\"container\" style=\"padding: 0 20px\">"
}

function endReportCreation {
    appendReportLine "</div>"
    appendReportLine "</body>"
    appendReportLine "</html>"
}

function search {
    local lineCounter=0

    appendReportLine "<h3>$3</h3>"
    appendReportLine "<div>"
    appendReportLine "<table border=1 style=\"width: 100%;table-layout: fixed;\">"
    appendReportLine "<tr>"
    appendReportLine "<th width=\"5%\">#</th>"
    appendReportLine "<th width=\"30%\">Location</th>"
    appendReportLine "<th width=\"57%\">Content</th>"
    appendReportLine "<th width=\"8%\">Confirm?</th>"
    appendReportLine "</tr>"

    grep $2 -IrinH . | while read -r line ; do
        local fileLocation=`echo $line | cut -d: -f1-2`
        local fileName=`basename $fileLocation`
        local lineNumber=`echo $line | cut -d: -f3`
        local comment=`echo $line | cut -d: -f4-`

        appendReportLine "<tr>"
        appendReportLine "<td align=\"center\">$lineCounter</td>"
        appendReportLine "<td><a href="$fileLocation">$fileName ($lineNumber)</a></td>"
        appendReportLine "<td>$comment</td>"
        appendReportLine "<td align=\"center\"><input type=\"checkbox\"></td>"
        appendReportLine "</tr>"

        lineCounter=$((lineCounter + 1))
    done

    appendReportLine "</table>"
    appendReportLine "</div>"
}

function searchForSensitiveWords {
    search $1 $sensitiveWords "Sensitive words found"
}

function searchForSensitiveHttpComponents {
    search $1 $sensitiveHttpComponents "Http related code found"
}

function searchForSensitiveSQLComponents {
    search $1 $sensitiveSQLComponents "SQL related code found"
}

function searchForSensitiveSerializationsComponents {
    search $1 $sensitiveSerializationsComponents "Serialization related code found"
}

function searchForSensitiveAuthenticationComponents {
    search $1 $sensitiveAuthenticationComponents "Authentication related code found"
}

printf "[INFO] Starting scan."
start=`date +%s`
git clone "$1" &
sleep 30
cd "$projectName"
startReportCreation $1
searchForSensitiveWords $1
searchForSensitiveHttpComponents $1
searchForSensitiveSQLComponents $1
searchForSensitiveSerializationsComponents $1
searchForSensitiveAuthenticationComponents $1
endReportCreation
end=`date +%s`
runtime=$((end-start))
echo "[INFO] Scan completed."
echo "[INFO] Execution time: $runtime secs."

exit 0