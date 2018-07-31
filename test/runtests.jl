using URIParser
using Test

urls = ["hdfs://user:password@hdfshost:9000/root/folder/file.csv#frag",
    "https://user:password@httphost:9000/path1/path2;paramstring?q=a&p=r#frag",
    "https://user:password@httphost:9000/path1/path2?q=a&p=r#frag",
    "https://user:password@httphost:9000/path1/path2;paramstring#frag",
    "https://user:password@httphost:9000/path1/path2#frag",
    "file:///path/to/file/with%3fshould%3dwork%23fine",
    "ftp://ftp.is.co.za/rfc/rfc1808.txt", "http://www.ietf.org/rfc/rfc2396.txt",
    "ldap://[2001:db8::7]/c=GB?objectClass?one", "mailto:John.Doe@example.com",
    "news:comp.infosystems.www.servers.unix", "tel:+1-816-555-1212", "telnet://192.0.2.16:80/",
    "urn:oasis:names:specification:docbook:dtd:xml:4.1.2"]

failed = 0
for url in urls
    global failed
    u = URI(url)
    if !(string(u) == url) || !isvalid(u)
        failed += 1
        println("Test failed for ",url)
    end
end
if failed != 0
    exit(failed)
end

@test URI("hdfs://user:password@hdfshost:9000/root/folder/file.csv") == URI("hdfs","hdfshost",9000,"/root/folder/file.csv","","","user:password")
@test URI("google.com","/some/path") == URI("http://google.com:80/some/path")
g = URI("google.com","/some/path")
@test URI(g,port=160) == URI("http://google.com:160/some/path")

@test escape("abcdef αβ 1234-=~!@#\$()_+{}|[]a;") == "abcdef%20%CE%B1%CE%B2%201234-%3D~%21%40%23%24%28%29_%2B%7B%7D%7C%5B%5Da%3B"
@test unescape(escape("abcdef 1234-=~!@#\$()_+{}|[]a;")) == "abcdef 1234-=~!@#\$()_+{}|[]a;"
@test unescape(escape("👽")) == "👽"

@test escape_form("abcdef 1234-=~!@#\$()_+{}|[]a;") == "abcdef+1234-%3D~%21%40%23%24%28%29_%2B%7B%7D%7C%5B%5Da%3B"
@test unescape_form(escape_form("abcdef 1234-=~!@#\$()_+{}|[]a;")) == "abcdef 1234-=~!@#\$()_+{}|[]a;"

@test ("user", "password") == userinfo(URI("https://user:password@httphost:9000/path1/path2;paramstring?q=a&p=r#frag"))
@test URI("https://user:password@httphost:9000/path1/path2;paramstring?q=a&p=r") == defrag(URI("https://user:password@httphost:9000/path1/path2;paramstring?q=a&p=r#frag"))

@test ["dc","example","dc","com"] == path_params(URI("ldap://ldap.example.com/dc=example,dc=com"))[1]
@test ["servlet","jsessionid","OI24B9ASD7BSSD"] == path_params(URI("http://www.mysite.com/servlet;jsessionid=OI24B9ASD7BSSD"))[1]

@test Dict("q"=>"a","p"=>"r") == query_params(URI("https://httphost/path1/path2;paramstring?q=a&p=r#frag"))
@test Dict("q"=>"a","malformed"=>"") == query_params(URI("https://foo.net/?q=a&malformed"))

@test false == isvalid(URI("file:///path/to/file/with?should=work#fine"))
@test true == isvalid(URI("file:///path/to/file/with%3fshould%3dwork%23fine"))

@test URI("s3://bucket/key") == URI("s3","bucket",0,"/key")

@test sprint(show, URI("http://google.com")) == "URI(http://google.com/)"

# Error paths
# Non-ASCII characters
@test_throws ErrorException URI("http://🍕.com")
# Unexpected start of URL
@test_throws ErrorException URI(".google.com")
# Unexpected character after scheme
@test_throws ErrorException URI("ht!tp://google.com")

#  Issue #27
@test URIParser.escape("t est\n") == "t%20est%0A"

# Issue #2
@test sprint(show, MIME("text/html"), URI("http://google.com")) ==
    """<a href="http://google.com/">http://google.com/</a>"""
