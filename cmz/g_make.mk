# If this file is missing, then automagically run the rule below
include ${INC}/google.mk

# This rule makes a file with the authorization token for
# spreadsheets.  See
# http://code.google.com/apis/gdata/articles/using_cURL.html for more
# information.  This needs to be run like: 'make
# email=qjhart@gmail.com pw=quinnIsGreat`, but then you don't have to
# supply that for as long as the token is valid
# curl --output $@ --header "Authorization: GoogleLogin auth=${wise-auth}" ${url}
${INC}/google.mk:
       curl https://www.google.com/accounts/ClientLogin \
       -d 'Email=${email}' -d 'Passwd=${pw}' \
       -d accountType=GOOGLE -d source=fundingwizard \
       -d service=wise | grep '^Auth' | sed -e 's/^Auth=/wise-auth:' > $@;`