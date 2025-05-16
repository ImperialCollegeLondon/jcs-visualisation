function clean = clean_key(key)
    clean = strip(key);
    clean = regexprep(clean, "\(.*\)", "");
    % clean = matlab.lang.makeValidName(strtrim(clean));
    clean = regexprep(clean, '\W', '_');
    clean = regexprep(clean, '^\d*_*', '');
    clean = regexprep(clean, '_$', '');

end