function _gh_set_output_println(gh_set_output::Bool, gh_set_output_io::IO, name, value)::Nothing
    if gh_set_output
        _gh_set_output_println(gh_set_output_io,
                               name,
                               value)
    end
    return nothing
end

function _gh_set_output_println(gh_set_output_io::IO, name, value)::Nothing
    println(gh_set_output_io, "::set-output name=$(name)::$(value)")
    return nothing
end
