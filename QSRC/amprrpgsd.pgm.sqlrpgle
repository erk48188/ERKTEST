      *%METADATA                                                       *
      * %TEXT RPG Common: Service Program Declares                     *
      *%EMETADATA                                                      *
     /if defined(_AMPRRPGSD)
     /Eof
     /Endif
     /define  _AMPRRPGSD
     *====================================================================
      *
      *   Description: Copy book for File Data Structure Defines
      *
     *====================================================================
      *       L O G   O F   P R O G R A M   M O D I F I C A T I O N S
     *====================================================================
      *   Date      Programmer       Description of Modifications & Reasons
      * --------    ----------       --------------------------------------
     *====================================================================
     *====================================================================
      *             F I L E     S P E C I F I C A T I O N S
     *====================================================================

     *====================================================================
      *          T A B L E S   A N D  A R R A Y S
     *====================================================================

      /if not defined (AMPRSERVICEPROGRAM)
       // * NOTE! These are TEMPLATES (no memory assigned) until
       // *       CreateDynamicArray called!
       dcl-c CntsElements 25;
       dcl-s CNTS int(10) dim(CntsElements) inz;

       dcl-c TITLE  1;
       dcl-c rRead  2;
       dcl-c rPrcd  3;
       dcl-c rUnpr  4;
       dcl-c rHorT  5;
       dcl-c rLtrs  6;

       dcl-c rInvL  4;


        // ------------------------------------------
        // -- CountBadLetterCode
        // ------------------------------------------
        dcl-pr CountBadLetterCode;
          LetterCodeDataStructure likeds(dsLCCnt) dim(150);
          LetterCode char(12) value;
        end-pr;

        // ------------------------------------------
        // -- CountLetterCode
        // ------------------------------------------
        dcl-pr CountLetterCode;
          LetterCodeDataStructure likeds(dsLCCnt) dim(150);
          LetterCode char(12) value;
        end-pr;

        // ------------------------------------------
        // -- CreateDynamicArray
        // ------------------------------------------
        dcl-pr CreateDynamicArray pointer;
          sLN char(10) value;
          sFN char(10) value;
        end-pr;

     *====================================================================

      /define AMPRSERVICEPROGRAM
      /endif
