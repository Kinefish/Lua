#ifndef __AHPP__
#define __AHPP__
#include <iostream>
#include "object.hpp"
#include "./test/malloc_allocator.hpp"
using namespace std;
using namespace ice::object;

class A {
    private:
        typedef ObjectPool<A, MallocAllocator<A>> ObjectPool;
        static ObjectPool pool;
    public:
     A(){
        std::cout << "class A constructor is running" << std::endl;
     }
     ~A(){
        std::cout << "class A destory is running" << std::endl;        
     }

     //运算符重载
    void * operator new(size_t n){
        std::cout << "A new rewrite is running" << std::endl;
        return pool.allocate(n);
    }
     //运算符重载
    void  operator delete(void *p){
        std::cout << "A delete rewrite is running" << std::endl;
        return pool.deallocate(p);
    }
};

#endif