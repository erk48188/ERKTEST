      *%METADATA                                                       *
      * %TEXT Update 002P File with Junk Mail Info                     *
      *%EMETADATA                                                      *
     *====================================================================
      *
      *   Description: Fill NCOA Fields with Data - FOR TESTING
      *
     *====================================================================
       ctl-opt Copyright('2018 Renkim Corporation');
       ctl-opt Option(*NoDebugIO: *srcstmt: *nounref);
       //ctl-opt AlwNull(*INPUTONLY);
       ctl-opt AlwNull(*USRCTL);
       ctl-opt dftactgrp(*no) actgrp(*new);
       exec sql set option commit=*none, closqlcsr=*endmod;

     *====================================================================
      * FILE SPECIFICATIONS
     *====================================================================
     FAMPR002P  uf   e             disk

     *====================================================================
      *               T A B L E S   &   A R R A Y S
     *====================================================================

     *====================================================================
      *                D A T A   S T R U C T U R E S
     *====================================================================

     * Program Status Data Structure
     D                sds
     D Program                       10a
     D Job                   244    253a
     D User                          10a
     D ExDte                 276    281s 0
     D ExTim                          6s 0

       dcl-s nRkcid char(12);
       dcl-s oRkcid char(12);


     *====================================================================
      *            F I E L D   D E F I N I T I O N S
     *====================================================================
     D Ix              s              4s 0 inz
     D RecIn           s              9s 0 inz

     D IsoDate         s               d   datfmt( *iso )
     D UsaDate         s               d   datfmt( *usa )

     D No              c                   const( 'N' )
     D Yes             c                   const( 'Y' )

     *====================================================================
      *       K E Y    F I E L D S   &   P A R M S   L I S T
     *====================================================================

     *====================================================================
      *              M A I N L I N E   R O U T I N E
     *====================================================================

     C                   read      RKMC002r

     C                   dow       not %eof
     C                   eval      RecIn      =  RecIn + 1

     C                   exsr      UpdateFlds

     C                   read      RKMC002r
     C                   enddo

     C                   eval      *inlr      =  *on

     *====================================================================
      *              S U B R O U T I N E   S E C T I O N
     *====================================================================

     *====================================================================
     Csr   UpdateFlds    begsr
     *--------------------------------------------------------------------
     C
     C                   eval      Sc1Ad1     =  RkAddr1
     C                   eval      Sc1Ad2     =  RkAddr2
     C                   eval      ScCity     =  RkCity
     C                   eval      ScSte      =  RkState
     C                   eval      Sc1Zip     =  RkZip

     * Load Junk Data
       if rkzip = '';
         rkzip = '12345-1234';
       endif;

     C                   if        %subst( RkZip : 6 : 5 )
     C                                        =  *blank
     C                   eval      %subst( RkZip : 6 : 5 )
     C                                        =  '-1234'
     C                   eval      Sc1Zp4     =  '1234'
     C                   else
     C                   eval      Sc1Zp4     =  %subst( RkZip : 7 : 4 )
     C                   endif

     C                   eval      sfDPBC     =  '01'
     C                   eval      sFChDt     =  '0'
     C                   eval      sBTNo      =  '000000001'
       orkcid = rkcid;
     C                   eval      sSeq#      =  %editc( RecIn : 'X' )

     C                   eval      RkcId      =  '999' + sseq#
        if evtZip4 = '';
          evtZip4 = 'P01';
        endif;

       nRkcid = rkcid;
       exec sql update ampr005p set rkcid = :nRkcid
                   where rkcid = :oRkcid;


     C                   update    RKMC002r

     Csr                 endsr

     *====================================================================
      *          O U T P U T   S P E C I F I C A T I O N S
     *====================================================================

