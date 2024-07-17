#ifndef __ALLOCATORHPP__
#define __ALLOCATORHPP__

namespace ice {
    namespace object {
        template <typename T>
        class Allocator {
            public:
                virtual T * allocate() = 0;
                virtual void deallocate(T * p) = 0;
        };
    }
}

#endif