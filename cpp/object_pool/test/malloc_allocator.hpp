#ifndef __MALLOC_ALLOCATORHPP__
#define __MALLOC_ALLOCATORHPP__
#include "../allocator.hpp"

namespace ice{
    namespace object{
        template<typename T>
        class MallocAllocator : public Allocator<T>{
            public:
                MallocAllocator() = default;
                ~MallocAllocator() = default;

                virtual T* allocate(){
                    auto p = ::malloc(sizeof(T));
                    return reinterpret_cast<T *>(p);
                }
                virtual void deallocate(T * p){
                    ::free(p);
                }
        };
    }
}
#endif