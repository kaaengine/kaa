#include <functional>


template<typename T>
std::size_t calculate_hash(const T& val)
{
    return std::hash<T>{}(val);
}
