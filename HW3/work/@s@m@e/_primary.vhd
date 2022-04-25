library verilog;
use verilog.vl_types.all;
entity SME is
    generic(
        IDLE            : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        Matching        : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        StringInput     : vl_logic_vector(0 to 1) := (Hi1, Hi0);
        PatternInput    : vl_logic_vector(0 to 1) := (Hi1, Hi1);
        period          : vl_logic_vector(0 to 7) := (Hi0, Hi0, Hi1, Hi0, Hi1, Hi1, Hi1, Hi0);
        caret           : vl_logic_vector(0 to 7) := (Hi0, Hi1, Hi0, Hi1, Hi1, Hi1, Hi1, Hi0);
        dollar          : vl_logic_vector(0 to 7) := (Hi0, Hi0, Hi1, Hi0, Hi0, Hi1, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        chardata        : in     vl_logic_vector(7 downto 0);
        isstring        : in     vl_logic;
        ispattern       : in     vl_logic;
        valid           : out    vl_logic;
        match           : out    vl_logic;
        match_index     : out    vl_logic_vector(4 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of Matching : constant is 1;
    attribute mti_svvh_generic_type of StringInput : constant is 1;
    attribute mti_svvh_generic_type of PatternInput : constant is 1;
    attribute mti_svvh_generic_type of period : constant is 1;
    attribute mti_svvh_generic_type of caret : constant is 1;
    attribute mti_svvh_generic_type of dollar : constant is 1;
end SME;
