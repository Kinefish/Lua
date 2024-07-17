#ifndef __OBJECTHPP__
#define __OBJECTHPP__
#include "allocator.hpp"

namespace ice {
    namespace object {
        template<typename T, typename Allocator>
        class ObjectPool {
            public:
                ObjectPool() = default;
                ~ObjectPool() = default;

                void * allocate(size_t n){
                    return m_allocator.allocate();
                }
                void deallocate(void * p){
                    return m_allocator.deallocate(static_cast<T *>(p));
                }
            private:
                Allocator m_allocator;
        };
    }
}

#endif