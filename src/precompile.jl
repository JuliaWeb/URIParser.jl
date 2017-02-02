function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(URIParser.parse_url, (Compat.ASCIIString,))
    precompile(URIParser.parse_authority, (Compat.ASCIIString, Bool,))
    precompile(URIParser.escape_with, (Compat.ASCIIString, Compat.String,))
    precompile(URIParser.is_host_char, (Char,))
    precompile(URIParser.is_url_char, (Char,))
    precompile(URIParser.isnum, (Char,))
    precompile(URIParser.is_mark, (Char,))
    precompile(URIParser.is_userinfo_char, (Char,))
    precompile(URIParser.escape, (Compat.ASCIIString,))
    precompile(URIParser.ishex, (Char,))
end
