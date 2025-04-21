      *%METADATA                                                       *
      * %TEXT Service Program - Common Routines                        *
      *%EMETADATA                                                      *
     *====================================================================
       ctl-opt Copyright('2016 Renkim Corporation');
       ctl-opt NOMAIN;

       exec sql set option commit=*none, closqlcsr=*endmod;

      *
     *====================================================================
      * Instructions
      *
      *  TO COMPILE -
      *    - Add Subprocedure to source .. rkmcSrvPgm
      *    - Add Prototypes to source .... rkmcSrvPro
      *    - Add Entries to source ....... rkmcSrvBnd
      *    - Compile with CRTSQLRPGI  RPGPPOPT(*LVL2)  DBGVIEW(*SOURCE)
      *  TO USE -
      *    - Add to pgm     ctl-opt dftactgrp(*no) actgrp(*new);
      *                     ctl-opt bnddir('RKMCBNDDIR');
     *====================================================================

     *====================================================================
      *             F I L E     S P E C I F I C A T I O N S
     *====================================================================

     *====================================================================
      *          G L O B A L   C O P I E S
     *====================================================================


      /copy 'QSRC/amprrpg.rpgleinc'

     *====================================================================
      *    I N T E R N A L   P R O T O T Y P E S
     *====================================================================
     *====================================================================
      *    S U B P R O C E D U R E S
     *====================================================================
      // ------------------------------------------
      // -- @spWriteEventFile
      //   pass as @UpdateEventFile(dsUEF: evt: evtMSG: pgmDS);
      // ------------------------------------------
       dcl-proc @spWriteEventFile export;
         dcl-pi *n;
           spUEF    likeds(dsUEF);
           spEvt    likeds(Evt);
           spEvtMsg char(70) dim(20);
           spPgmDS  likeds(pgmDS);
         end-pi;

         dcl-ds x020 likeds(r020);
         dcl-ds y020 likeds(r020);
         dcl-s y020Null like(r020null);

         dcl-s keyf like(iIndex);
         //dcl-s EventMsg char(70) dim(20) based(pspEM);
         //dcl-s pspEM pointer;


         if spuef.uef_Initialized <> 'Y';
           //clear dsUEF;
           spuef.iindex = 0;
           spuef.uef_Initialized = 'Y';
         endif;

         spuef.iIndex += 1;
         eval-corr x020 = spevt;
         keyf = spuef.iIndex + spuef.iBase;
         x020.ekeyf = %editc(keyf:'X');
         x020.eProg  = spPgmDS.Program;
         if spEvt.eDesc = '';
           monitor;
             x020.eDesc = spEvtMsg(spuef.iIndex);
           on-error;
             x020.eDesc = '** DESC Error: Index <' + %editc(spuef.iIndex:'2')
                          + '> not found in EvtMsg Array';
           endmon;
         endif;
         exec sql select * into :y020 :y020Null
           from AMPR020p where ekeyf = :x020.ekeyf;

         if sqlcod = 0;
           x020.ecount += y020.ecount;
           exec sql delete from AMPR020p where ekeyf = :x020.ekeyf;
         endif;

         exec sql insert into AMPR020p values (:x020);
         clear x020;
         clear spEvt;
       end-proc @spWriteEventFile;

      // ------------------------------------------
      // -- @spGetTierCounts
      //   pass as @spGetTierCounts(errorCode: RecsArray);
      // ------------------------------------------
       dcl-proc @spGetTierCounts export;
         dcl-pi *n;
          spEC     char(4);
          spAr     like(RecsRead) dim(4);
         end-pi;

         dcl-s z9 zoned(9:0);

         for ix = 1 to cNumberOfTiers;
           exec sql select count(*) into :z9
             from ampr002p where rkReason = :spEc
               and indLangVg = cast(:ix as char(1));
           spAr(ix) = z9;
         endfor;

       end-proc @spGetTierCounts;

      // ------------------------------------------
      // -- @spGetTierCountsAnyReason
      //   pass as @spGetTierCountsAnyReason(RecsArray);
      // ------------------------------------------
       dcl-proc @spGetTierCountsAnyReason export;
         dcl-pi *n;
          spAr     like(RecsRead) dim(4);
         end-pi;

         dcl-s z9 zoned(9:0);

         for ix = 1 to cNumberOfTiers;
           exec sql select count(*) into :z9
             from ampr002p where rkReason <> ''
               and indLangVg = cast(:ix as char(1));
           spAr(ix) = z9;
         endfor;

       end-proc @spGetTierCountsAnyReason;

       // ------------------------------------------
       // -- @spWriteAuditRecord
       // ------------------------------------------
        dcl-proc @spWriteAuditRecord export;
          dcl-pi *n;
             iDSIndex         int(5) value;
             @warEvtMsg       char(70) value;
             @warLevel        char(1) value;
             @warTotal        char(1) value;
             @warSumFld       zoned(4:0) value;
             @warWFDSumFld    zoned(4:0) value;
             @warJob          char(3) value;
          end-pi;

          for ix = 1 to cNumberOfTiers + 1;
            evt.eTier     = @aFlTr(ix);
            evt.eCount    = @TierCount(iDSIndex).count(ix);
            evt.eDesc     = %trim(@warevtMsg) + @sFlTr(ix);
            evt.eJob#     = @warJob;
            evt.eTotal    = @warTotal;
            evt.eLevel    = @warLevel;
            evt.eSumFld   = @warSumFld;
            evt.eWFSumFld = @warWFDSumFld;
            evt.eEvtCd    = 'derp';
            @spWriteEventFileNoMsg(dsUEF: evt: pgmDS);
          endfor;

        end-proc @spWriteAuditRecord;

      // ------------------------------------------
      // -- @spWriteEventFileNoMsg
      //   pass as @spWriteEventFileNoMsg(dsUEF: evt: pgmDS);
      // ------------------------------------------
       dcl-proc @spWriteEventFileNoMsg export;
         dcl-pi *n;
           spUEF    likeds(dsUEF);
           spEvt    likeds(Evt);
           spPgmDS  likeds(pgmDS);
         end-pi;

         dcl-ds x020 likeds(r020);
         dcl-ds y020 likeds(r020);
         dcl-s y020Null like(r020null);

         dcl-s keyf like(iIndex);


         if spuef.uef_Initialized <> 'Y';
           spuef.iindex = 0;
           spuef.uef_Initialized = 'Y';
         endif;

         spuef.iIndex += 1;
         eval-corr x020 = spevt;
         keyf = spuef.iIndex + spuef.iBase;
         x020.ekeyf = %editc(keyf:'X');
         x020.eProg  = spPgmDS.Program;
         exec sql select * into :y020 :y020Null
           from AMPR020p where ekeyf = :x020.ekeyf;

         if sqlcod = 0;
           x020.ecount += y020.ecount;
           exec sql delete from AMPR020p where ekeyf = :x020.ekeyf;
         endif;

         exec sql insert into AMPR020p values (:x020);
         clear x020;
         clear spEvt;
       end-proc @spWriteEventFileNoMsg;

