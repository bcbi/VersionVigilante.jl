function always_assert(cond::Bool, msg::AbstractString)::Nothing
    _msg::String = convert(String, msg)::String
    cond || throw(AlwaysAssertionError(_msg))
    return nothing
end
