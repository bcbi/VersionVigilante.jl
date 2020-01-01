struct AlwaysAssertionError <: Exception
    msg::String
end

struct IsPrerelease end
struct NotPrerelease end
