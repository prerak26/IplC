#ifndef AST_HH
#define AST_HH

#include "type.hh"
#include "rstack.hh"
#include <vector>

namespace IPL
{
    class abstract_astnode
    {
    protected:
        ASTNodeType node_type;
        int label;

    public:
        virtual ~abstract_astnode() {}
        virtual std::vector<std::string> tree_traversal() = 0;
        virtual void generate_code(bool lvalue) = 0;
        ASTNodeType get_node_type();
        void set_node_type(ASTNodeType type);
        int get_label();
        void set_label(int label);
    };

    class statement_astnode : public abstract_astnode
    {
    protected:
        std::vector<int> nextlist;

    public:
        virtual ~statement_astnode() {}
        std::vector<int> get_nextlist();
        void set_nextlist(std::vector<int> nextlist);
    };
    class expression_astnode : public abstract_astnode
    {
    protected:
        Address *address;
        std::vector<int> truelist;
        std::vector<int> falselist;
        bool is_bool = false;
        Type *type;
        bool is_lvalue;

    public:
        virtual ~expression_astnode() {}
        Address *get_address();
        void set_address(Address *address);
        std::vector<int> get_truelist();
        void set_truelist(std::vector<int> truelist);
        std::vector<int> get_falselist();
        void set_falselist(std::vector<int> falselist);
        std::string to_arithmetic();
        void to_boolean();
        bool get_is_bool();
        bool get_is_lvalue();
        void set_is_lvalue(bool is_lvalue);
        Type *get_type();
        void set_type(Type *type);

    };
    class reference_astnode : public expression_astnode
    {
    public:
        virtual ~reference_astnode() {}
    };
    class iteration_astnode : public statement_astnode
    {
    public:
        virtual ~iteration_astnode() {}
    };

    class identifier_astnode : public reference_astnode
    {
    private:
        std::string name;
        int offset;
        Scope scope;

    public:
        identifier_astnode(std::string name, int offset, Scope scope);
        Scope get_scope();
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class member_astnode : public reference_astnode
    {
    private:
        expression_astnode *expression;
        identifier_astnode *name;

    public:
        member_astnode(expression_astnode *expression, identifier_astnode *name);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class array_astnode : public reference_astnode
    {
    private:
        expression_astnode *expression;
        expression_astnode *index;

    public:
        array_astnode(expression_astnode *expression, expression_astnode *index);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class arrow_astnode : public reference_astnode
    {
    private:
        expression_astnode *expression;
        identifier_astnode *name;

    public:
        arrow_astnode(expression_astnode *expression, identifier_astnode *name);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };

    class op_binary_astnode : public expression_astnode
    {
    private:
        expression_astnode *left;
        expression_astnode *right;
        OP_Binary op;

    public:
        op_binary_astnode(expression_astnode *left, expression_astnode *right, OP_Binary op);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class op_unary_astnode : public expression_astnode
    {
    private:
        expression_astnode *expression;
        OP_Unary op;

    public:
        op_unary_astnode(expression_astnode *expression, OP_Unary op);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class int_astnode : public expression_astnode
    {
    private:
        int value;
    public:
        int_astnode(int value);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class string_astnode : public expression_astnode
    {
    private:
        std::string value;
        std::string reference;

    public:
        string_astnode(std::string value);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
        std::string get_reference();
    };
    class assignE_astnode : public expression_astnode
    {
    private:
        expression_astnode *left;
        expression_astnode *right;

    public:
        assignE_astnode(expression_astnode *left, expression_astnode *right);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class funcall_astnode : public expression_astnode
    {
    private:
        std::string name;
        std::vector<expression_astnode *> arguments;
        int local_param_size;

    public:
        funcall_astnode(std::string name, int local_param_size);
        void add_argument(expression_astnode *argument);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };

    class seq_astnode : public statement_astnode
    {
    private:
        std::vector<statement_astnode *> statements;

    public:
        seq_astnode();
        void add_statement(statement_astnode *statement);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class empty_astnode : public statement_astnode
    {
    public:
        empty_astnode();
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class assignS_astnode : public statement_astnode
    {
    private:
        expression_astnode *assignment_expression;

    public:
        assignS_astnode(expression_astnode *assignment_expression);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class if_astnode : public statement_astnode
    {
    private:
        expression_astnode *condition;
        statement_astnode *if_body;
        statement_astnode *else_body;

    public:
        if_astnode(expression_astnode *condition, statement_astnode *if_body, statement_astnode *else_body);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class while_astnode : public iteration_astnode
    {
    private:
        expression_astnode *condition;
        statement_astnode *body;

    public:
        while_astnode(expression_astnode *condition, statement_astnode *body);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class for_astnode : public iteration_astnode
    {
    private:
        assignE_astnode *init;
        expression_astnode *condition;
        assignE_astnode *step;
        statement_astnode *body;

    public:
        for_astnode(assignE_astnode *init, expression_astnode *condition, assignE_astnode *step, statement_astnode *body);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class return_astnode : public statement_astnode
    {
    private:
        expression_astnode *expression;
        Address* return_address;
        int local_var_size;

    public:
        return_astnode(expression_astnode *expression, int return_value_offset, int local_var_size);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class proccall_astnode : public statement_astnode
    {
    private:
        std::string name;
        std::vector<expression_astnode *> arguments;
        int local_param_size;
        int return_size;

    public:
        proccall_astnode(std::string name, int local_param_size, int return_size);
        void add_argument(expression_astnode *argument);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };
    class printf_astnode : public statement_astnode
    {
    private:
        string_astnode *format;
        std::vector<expression_astnode *> arguments;
        int local_param_size;

    public:
        printf_astnode(string_astnode *format, int local_param_size);
        void add_argument(expression_astnode *argument);
        std::vector<std::string> tree_traversal();
        void generate_code(bool lvalue);
    };

    class compound_statement
    {
    private:
        seq_astnode *statements;
        int local_var_size;
        std::vector<std::string> runtime_constants;
        int label;
        bool is_void;

    public:
        compound_statement(seq_astnode *statements, int local_var_size, bool is_void);
        void populate_runtime_constants();
        void print_runtime_constants();
        void generate_code(std::string function_name);
    };

    class expression_list
    {
    private:
        std::vector<expression_astnode *> expressions;

    public:
        expression_list();
        void add_expression(expression_astnode *expression);
        std::vector<expression_astnode *> get_expressions();
    };
}
#endif