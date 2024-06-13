Student = {
    m_age = 1,
    m_name = "x",
    func_yel = function()
        print("this is func_yel ")
    end,
    func_getter = function(s)
        print("this func getting member age "..s.m_age)
        print("this func getting member name "..s.m_name)
    end,
    func_setter = function(s,age,name)
        s.m_age = age
        s.m_name = name  
    end,
    --[[
        无法调用func_inner(),因为没有self参数
    ]]
    func_inner = function()
        print(self.m_age)
        print(self.m_name)
    end
}

--↓↓↓ 语法糖 Student.func_getter(Student)
Student:func_getter()

Student:func_setter(18,"woowoowo")

Student:func_getter()

--如果用冒号在外部声明函数，那么会有默认参数self
function Student:func_outer()
    print(self.m_age)
    print(self.m_name)
end

--调用报错，没有self参数，不是冒号声明
function Student.func_new_outer()
    print(self.m_age)
    print(self.m_name)
end

Student.func_new_outer(Student)

Student:func_outer()
Student.func_yel()
-- Student.func_inner() / Student:func_inner() 会报错，self只能在外部：声明时调用?

