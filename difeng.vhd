------------------------------------------------------------------------------------------------------------
-- Importing the libraries
-------------------------------------------------------------------------------------------------------------

LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.STD_LOGIC_ARITH.ALL ;
USE IEEE.STD_LOGIC_SIGNED.ALL ;

------------------------------------------------------------------------------------------------------------
-- ENTITY named difference 
    -- specifying input (clk, reset_l)
    -- output ports (ca, cb, cc, cd, ce, cf, cg, an, dp).
-------------------------------------------------------------------------------------------------------------

ENTITY difference IS
   PORT (clk     : IN    STD_LOGIC ;
         reset_l : IN    STD_LOGIC ;
         ca      : OUT   STD_LOGIC ;
         cb      : OUT   STD_LOGIC ;
         cc      : OUT   STD_LOGIC ;
         cd      : OUT   STD_LOGIC ;
         ce      : OUT   STD_LOGIC ;
         cf      : OUT   STD_LOGIC ;
         cg      : OUT   STD_LOGIC ;
         an      : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0) ;
         dp      : OUT   STD_LOGIC) ;
END difference ;

------------------------------------------------------------------------------------------------------------
-- The ARCHITECTURE named "mine" for the difference entity
    -- declaring the signals, components, processes, and logic which are defined to describe the behavior of the circuit
-------------------------------------------------------------------------------------------------------------

ARCHITECTURE mine OF difference IS

   SIGNAL   f : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
   SIGNAL   g : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
   SIGNAL   h : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
   SIGNAL   i : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
   SIGNAL   j : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
   SIGNAL   reset_l_sync : STD_LOGIC ;
   SIGNAL   reset_l_tmp : STD_LOGIC ;
   SIGNAL   x : STD_LOGIC_VECTOR(7 DOWNTO 0) ;
   SIGNAL   ROOTS : STD_LOGIC_VECTOR(31 DOWNTO 0) ; -- ROOTS
   SIGNAL   ROOTCOUNTER : STD_LOGIC_VECTOR(2 DOWNTO 0) ; -- ROOT COUNTER
   SIGNAL   COUNTER : STD_LOGIC_VECTOR(19 DOWNTO 0) ; -- COUNTER
   SIGNAL   ahexchar : STD_LOGIC_VECTOR(3 DOWNTO 0) ; -- ahexchar
   SIGNAL   ca_int : STD_LOGIC ;
   SIGNAL   cb_int : STD_LOGIC ;
   SIGNAL   cc_int : STD_LOGIC ;
   SIGNAL   cd_int : STD_LOGIC ;
   SIGNAL   ce_int : STD_LOGIC ;
   SIGNAL   cf_int : STD_LOGIC ;
   SIGNAL   cg_int : STD_LOGIC ;
   SIGNAL   an_int : STD_LOGIC_VECTOR(7 DOWNTO 0) ;

---------------------------------------------------------------------------------------------------------------
-- COMPONENT named hex2cathode
    -- describing its input and output ports
---------------------------------------------------------------------------------------------------------------

COMPONENT hex2cathode
 Port (ahexchar : IN    STD_LOGIC_VECTOR(3 DOWNTO 0) ;
       ca       : OUT   STD_LOGIC ;
       cb       : OUT   STD_LOGIC ;
       cc       : OUT   STD_LOGIC ;
       cd       : OUT   STD_LOGIC ;
       ce       : OUT   STD_LOGIC ;
       cf       : OUT   STD_LOGIC ;
       cg       : OUT   STD_LOGIC) ;
 END COMPONENT ;
  
BEGIN

----------------------------------------------------------------------------------------------------------------
-- Assignment for the decimal point
----------------------------------------------------------------------------------------------------------------

dp <= '1';

----------------------------------------------------------------------------------------------------------------
-- 1ST FLIP-FLOP 
    -- for hex2cathode
    -- sensitive to clock
----------------------------------------------------------------------------------------------------------------

FLIPFLOP1: PROCESS (clk)
 BEGIN
    IF (clk'EVENT AND clk='1') 
            THEN  ca <= ca_int ;
                  cb <= cb_int ;
                  cc <= cc_int ;
                  cd <= cd_int ;
                  ce <= ce_int ;
                  cf <= cf_int ;
                  cg <= cg_int ;    
    END IF;
 END PROCESS FLIPFLOP1;

----------------------------------------------------------------------------------------------------------------
-- 2ND FLIP-FLOP 
    -- for DECODER
    -- sensitive to clock
----------------------------------------------------------------------------------------------------------------

FLIPFLOP2: PROCESS (clk)
 BEGIN
    IF (clk'EVENT AND clk='1') 
            THEN an <= an_int ;   
    END IF;
 END PROCESS FLIPFLOP2;

----------------------------------------------------------------------------------------------------------------
-- DECODER
    -- taking the three most significant bits of signal COUNTER to assign values to an_int
----------------------------------------------------------------------------------------------------------------

WITH COUNTER(19 DOWNTO 17) SELECT
    an_int <= "11111110" WHEN "000" ,
              "11111101" WHEN "001" ,
              "11111011" WHEN "010" ,
              "11110111" WHEN "011" ,
              "11101111" WHEN "100" ,
              "11011111" WHEN "101" ,
              "10111111" WHEN "110" ,
              "01111111" WHEN "111" ,
              "11111111" WHEN OTHERS ;

----------------------------------------------------------------------------------------------------------------
-- Port Mapping from hex2cathode.vhd
----------------------------------------------------------------------------------------------------------------

hexcathode:hex2cathode
PORT MAP(ahexchar => ahexchar,
         ca       => ca_int ,
         cb       => cb_int ,
         cc       => cc_int ,
         cd       => cd_int ,
         ce       => ce_int ,
         cf       => cf_int ,
         cg       => cg_int) ;

---------------------------------------------------------------------------------------------------------------
-- MUX
---------------------------------------------------------------------------------------------------------------

WITH COUNTER(19 DOWNTO 17) SELECT
    ahexchar <= ROOTS(3 DOWNTO 0) WHEN "000" ,
    ROOTS(7 DOWNTO 4) WHEN "001" ,
    ROOTS(11 DOWNTO 8) WHEN "010" ,
    ROOTS(15 DOWNTO 12) WHEN "011" ,
    ROOTS(19 DOWNTO 16) WHEN "100" ,
    ROOTS(23 DOWNTO 20) WHEN "101" ,
    ROOTS(27 DOWNTO 24) WHEN "110" ,
    ROOTS(31 DOWNTO 28) WHEN "111" ,
    ROOTS(3 DOWNTO 0) WHEN OTHERS ;

---------------------------------------------------------------------------------------------------------------
-- N-bit counter
---------------------------------------------------------------------------------------------------------------

 COUNTERS:PROCESS(clk)
   BEGIN
        IF (clk'event AND clk = '1') THEN
           IF (reset_l_sync = '0') THEN
            COUNTER <= "00000000000000000000";
           ELSE
            COUNTER <= COUNTER + 1;
           END IF ;
        END IF ;
   END PROCESS ;
   
---------------------------------------------------------------------------------------------------------------
-- adding the reset synchronizer from the "Reset Synchronizer.pdf" and editing the difference engine process to use "reset_l_sync" 
-- so the synthesized difference engine uses the synchronized reset instead of the asynchronous reset
---------------------------------------------------------------------------------------------------------------

PROCESS(clk)
BEGIN
    IF (clk'event AND clk = '1') THEN
        reset_l_tmp <= reset_l ;
        reset_l_sync <= reset_l_tmp ;
    END IF ;
END PROCESS ;

---------------------------------------------------------------------------------------------------------------
-- updating the signals f,g,h,i,j,x based on the clock and the synchronized reset signal
---------------------------------------------------------------------------------------------------------------

   registers:PROCESS(clk)
   BEGIN
        IF (clk'event AND clk = '1') THEN
           
           IF (reset_l_sync = '0') THEN
              f <= "00000000010000000000000000000000" ;
              g <= "11111111111110001100010100010001" ;
              h <= "00000000000000001000011001101110" ;
              i <= "11111111111111111111101010000100" ;
              j <= "00000000000000000000000000011000" ;
              x <= "00000000" ; 
           ELSE
              f <= f + g ;
              g <= g + h ;
              h <= h + i ;
              i <= i + j ;
              x <= x + 1 ;   
           END IF ;
        END IF ;
   END PROCESS ;
 
---------------------------------------------------------------------------------------------------------------
-- FINDING THE ROOTS
    -- when f(x) = 0, x is the root. 
    -- Assumed that the roots are real and less than 256 so they can be represented using an 8-bit (unsigned) value. 
    -- Difference engine process:
        -- updating on a rising clock edge after reset_l_sync is de-asserted 
        -- keeping the logic generated able to run as fast as possible in the target FPGA
---------------------------------------------------------------------------------------------------------------

   ROOTCAPTUREPROCESS:PROCESS(clk)
   BEGIN
        IF (clk'event AND clk = '1') THEN
           IF (reset_l_sync = '0') THEN
                ROOTS <= "00000000000000000000000000000000";
                ROOTCOUNTER <= "000";
            ELSE
                IF (f = "00000000000000000000000000000000") THEN
                    IF (ROOTCOUNTER = "000") THEN
                        ROOTS(7 DOWNTO 0) <= x ;
                        ROOTCOUNTER <= ROOTCOUNTER + 1 ;
                    END IF ;
               
                    IF (ROOTCOUNTER = "001") THEN
                        ROOTS(15 DOWNTO 8) <= x;
                        ROOTCOUNTER <= ROOTCOUNTER + 1 ;
                    END IF ;
                           
                    IF (ROOTCOUNTER = "010") THEN
                        ROOTS(23 DOWNTO 16) <= x;  
                        ROOTCOUNTER <= ROOTCOUNTER + 1 ;
                    END IF ;
                           
                    IF ROOTCOUNTER = "011" THEN
                        ROOTS(31 DOWNTO 24) <= x;
                        ROOTCOUNTER <= ROOTCOUNTER + 1 ;
                    END IF ;
 
                END IF ;           
            END IF ;
         END IF ;    
   END PROCESS ;

-----------------------------------------------------------------------------------------------------------

END mine ;
