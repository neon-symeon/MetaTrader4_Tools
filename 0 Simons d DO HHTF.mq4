//+------------------------------------------------------------------+
//|                                     Simon's DO HH TIME FRAME.mq4 |
//+------------------------------------------------------------------+
#property copyright "(c) Szymon Marek 2014-2018"
#property link      "www.SzymonMarek.com"
#property version   "1.00"

#property description "Simon's Dynamic Oscylator. This, and Higher, and Higher Time Frame"
#property description " "
#property description "Szczegóły opisu ustawień w oscylatorze bazowym Simons DO"
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DOT
#property indicator_level1 20
#property indicator_level2 50
#property indicator_level3 80
//+------------------------------------------------------------------+
#property indicator_buffers 8
//+------------------------------------------------------------------+
#property indicator_color1 clrLime        // fast line base tf
#property indicator_style1 STYLE_SOLID
#property indicator_width1 5

#property indicator_color2 clrRed     // slow time baser tf
#property indicator_style2 STYLE_SOLID
#property indicator_width2 5

#property indicator_color3 clrAqua       // fast line HTF
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

#property indicator_color4 clrMagenta         // slow line HTF
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

#property indicator_color5 clrAqua        //clrDarkGreen // fast line HHTF
#property indicator_width5 1
#property indicator_style5 STYLE_DOT

#property indicator_color6 clrMagenta         //clrBrown// slow line HHTF
#property indicator_width6 1
#property indicator_style6 STYLE_DOT

#property indicator_color7 clrLime
#property indicator_width7 3

#property indicator_color8 clrRed
#property indicator_width8 3
//+------------------------------------------------------------------+
double arr_FastLine_TTF[];
double arr_SlowLine_TTF[];

double arr_FastLine_HTF[];
double arr_SlowLine_HTF[];

double arr_FastLine_HHTF[];
double arr_SlowLine_HHTF[];
//
double arr_BullArrow[];
double arr_BearArrow[];
//+------------------------------------------------------------------+
//zmienne zewnętrzne
//+------------------------------------------------------------------+
//this time frame
extern string              s0="---------------------------";   //---
extern bool                blnE_Czy_TF_1st      = true;           //Czy Linie Oscylatora
extern ENUMS_DO_SET        enmE_Set_TF_1st      = set_1;          //Parametr DO
extern ENUM_TIMEFRAMES     enmE_TF_1st          = PERIOD_CURRENT; //current = Auto
extern ENUMS_DO_Line       enmE_ObOs_Line_TF_1st= line_slow;
//higher  time frame
extern string              s1="---------------------------";   //---
extern bool                blnE_Czy_TF_2nd      = true;           //Czy Linie HTF 
extern ENUMS_DO_SET        enmE_Set_TF_2nd      = set_1;          //Parametr DO
extern ENUM_TIMEFRAMES     enmE_TF_2nd          = PERIOD_CURRENT; //current = Auto
extern ENUMS_DO_Line       enmE_ObOs_Line_TF_2nd= line_slow;
//higher higher time frame
extern string              s2="---------------------------";   //---
extern bool                blnE_Czy_TF_3rd      = true;           //Czy Linie HHTF 
extern ENUMS_DO_SET        enmE_Set_TF_3rd      = set_1;          //Parametr DO
extern ENUM_TIMEFRAMES     enmE_TF_3rd          = PERIOD_CURRENT; //current = Auto
extern ENUMS_DO_Line       enmE_ObOs_Line_TF_3rd= line_fast;
extern string              s3="------- Trading Arrows -------";//---
//extern bool                blnE_Trading_Arrows  = true;         //Czy Strzałki
//extern bool                blnE_Triple_TF_Arrows  = true;       //Czy strzałki łącznie z 3x TF
extern bool                blnE_Arrows     = true;                //Czy strzałki z dwolnego HTF
//extern bool                blnE_Czy_A_TF_2nd    = true;         //Czy używać HTF do Strzałek
//extern bool                blnE_Czy_A_TF_3rd    = true;         //Czy używać HHTF do Strzałek
extern string              s4 = "--- Czy wyświetlać odczyty DO ---";//---
extern bool                blnE_Display_DO_Readings    = true;    //Czy Odczyty
extern string              s5="--- Alert automatycznych sygnałów Buy/Sell ---";  //---
extern bool                blnE_Czy_Alerts = false;
//+------------------------------------------------------------------+
//globalne zmienne
//+------------------------------------------------------------------+
int      intG_WinIdx;      //indeks okna wskaźnika
string   strG_NazwaIndi;   //nazwa indykatora
bool blnG_CzyNewBarHTF1 = true;
bool blnG_CzyNewBarHTF2 = true;
datetime dtmG_NewBarHTF;
ENUM_TIMEFRAMES   enmG_TF_1st, enmG_TF_2nd, enmG_TF_3rd;
string            strG_TF_1st, strG_TF_2nd, strG_TF_3rd;
string strG_Shade_Readings = "DO HTF Shade";
string strG_Readings_TTF_1 = "DO HTF Readings TTF 1";
string strG_Readings_HTF_1 = "DO HTF Readings HTF 1";
string strG_Readings_HTF_2 = "DO HTF Readings HTF 2";
bool blnG_Czy_Alerts = true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //---
   IndicatorDigits(1);

   //--- time frames
   if(enmE_TF_1st == PERIOD_CURRENT) enmG_TF_1st = Period();                           else enmG_TF_1st = enmE_TF_1st; //Alert(enmG_TF_1st);
   if(enmE_TF_2nd == PERIOD_CURRENT) enmG_TF_2nd = convert_TF_To_H_TF(enmG_TF_1st);    else enmG_TF_2nd = enmE_TF_2nd;
   if(enmE_TF_3rd == PERIOD_CURRENT) enmG_TF_3rd = convert_TF_To_H_TF(enmG_TF_2nd);    else enmG_TF_3rd = enmE_TF_3rd;
   
   strG_TF_1st = translate_TF(enmG_TF_1st);
   strG_TF_2nd = translate_TF(enmG_TF_2nd);
   strG_TF_3rd = translate_TF(enmG_TF_3rd);
   
   //nazwa oscylatora, gdy wszystko już ustawione   
   strG_NazwaIndi = "Simon's 2x Higher Time Frame DO|";

   string strL_N_TF_1  = strG_TF_1st+"."+translate_DO_settings(enmE_Set_TF_1st);
   string strL_N_TF_2  = strG_TF_2nd+"."+translate_DO_settings(enmE_Set_TF_2nd);
   string strL_N_TF_3  = strG_TF_3rd+"."+translate_DO_settings(enmE_Set_TF_3rd);
   
   //if(check_dif_DO_set_4_display(enmG_TF_1st,enmE_Set_TF_1st,enmG_TF_2nd,enmE_Set_TF_1st)) strL_N_TF_1  = strG_TF_1st+"."+translate_DO_settings(enmE_Set_TF_1st);
   //if(check_dif_DO_set_4_display(enmG_TF_1st,enmE_Set_TF_1st,enmG_TF_2nd,enmE_Set_TF_2nd)) strL_N_TF_2  = strG_TF_2nd+"."+translate_DO_settings(enmE_Set_TF_2nd);
   //if(check_dif_DO_set_4_display(enmG_TF_2nd,enmE_Set_TF_2nd,enmG_TF_3rd,enmE_Set_TF_3rd)) strL_N_TF_3  = strG_TF_3rd+"."+translate_DO_settings(enmE_Set_TF_3rd);
   
   if(blnE_Czy_TF_1st)                                                                                   strG_NazwaIndi = strG_NazwaIndi + strL_N_TF_1;
   if(blnE_Czy_TF_1st && blnE_Czy_TF_2nd)                                                                strG_NazwaIndi = strG_NazwaIndi+";";
   if(blnE_Czy_TF_2nd)                                                                                   strG_NazwaIndi = strG_NazwaIndi+strL_N_TF_2;
   if(blnE_Czy_TF_2nd && blnE_Czy_TF_3rd)                                                                strG_NazwaIndi = strG_NazwaIndi+";";
   if(blnE_Czy_TF_3rd)                                                                                   strG_NazwaIndi = strG_NazwaIndi+strL_N_TF_3;   
   strG_NazwaIndi = strG_NazwaIndi + "|";
   if(blnE_Czy_Alerts)                                      strG_NazwaIndi = strG_NazwaIndi + " ALERTS";   
   IndicatorShortName(strG_NazwaIndi);
   
   //--- mapowanie
   SetIndexBuffer(0,arr_FastLine_TTF);    SetIndexStyle(0,DRAW_LINE);   SetIndexLabel(0,"Fast Line 1st " + strG_TF_1st);
   SetIndexBuffer(1,arr_SlowLine_TTF);    SetIndexStyle(1,DRAW_LINE);   SetIndexLabel(1,"Slow Line 1st " + strG_TF_1st);
   SetIndexBuffer(2,arr_FastLine_HTF);    SetIndexStyle(2,DRAW_LINE);   SetIndexLabel(2,"Fast Line 2nd " + strG_TF_2nd);
   SetIndexBuffer(3,arr_SlowLine_HTF);    SetIndexStyle(3,DRAW_LINE);   SetIndexLabel(3,"Slow Line 2nd " + strG_TF_2nd);
   SetIndexBuffer(4,arr_FastLine_HHTF);   SetIndexStyle(4,DRAW_LINE);   SetIndexLabel(4,"Fast Line 3rd " + strG_TF_3rd);
   SetIndexBuffer(5,arr_SlowLine_HHTF);   SetIndexStyle(5,DRAW_LINE);   SetIndexLabel(5,"Slow Line 3rd " + strG_TF_3rd);
   SetIndexBuffer(6,arr_BullArrow);       SetIndexStyle(6,DRAW_ARROW);  SetIndexLabel(6,"Bull Arrow");SetIndexArrow(6,233);SetIndexEmptyValue(6,0.0);
   SetIndexBuffer(7,arr_BearArrow);       SetIndexStyle(7,DRAW_ARROW);  SetIndexLabel(7,"Bear Arrow");SetIndexArrow(7,234);SetIndexEmptyValue(7,0.0);
   
   int intL_DrBgn=23;
   
   SetIndexDrawBegin(0,intL_DrBgn);
   SetIndexDrawBegin(1,intL_DrBgn);
   SetIndexDrawBegin(2,intL_DrBgn);
   SetIndexDrawBegin(3,intL_DrBgn);
   SetIndexDrawBegin(4,intL_DrBgn);
   SetIndexDrawBegin(5,intL_DrBgn);
    
   if(!blnE_Czy_TF_1st)
   {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
   }

   if(!blnE_Czy_TF_2nd)
   {
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
   }
   
   if(!blnE_Czy_TF_3rd)
   {
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);
   }

   //if(!blnE_Triple_TF_Arrows)//Trading_Arrows)
   //{
   //   SetIndexStyle(6,DRAW_NONE);
   //   SetIndexStyle(7,DRAW_NONE);
   //}

   intG_WinIdx=WindowFind(strG_NazwaIndi);
   
   //readings
   if(blnE_Display_DO_Readings)show_Readings();else delete_Readings();
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
   int intL_BTC = rates_total-prev_calculated+1;
   
   if       (prev_calculated==0)             intL_BTC=Bars-1; 
   else if  (prev_calculated==rates_total)   intL_BTC=0;
   else
   {
      //
      blnG_Czy_Alerts = true;
      //   
      if(iBarShift(NULL,enmG_TF_3rd,Time[0]) != iBarShift(NULL,enmG_TF_3rd,Time[1]))
      {
         for(int i=2;i<Bars-1;i++)
         if(iBarShift(NULL,enmG_TF_3rd,Time[i])!=iBarShift(NULL,enmG_TF_3rd,Time[i+1]))
         {
            intL_BTC  = i+1;
            //Alert("TF=",strG_TF_1st,"; ",Symbol()," ",strG_TF_3rd," ",strG_NazwaIndi," Bars To Calculate: ",intL_BTC);
            break;
         }
      }
      else if(iBarShift(NULL,enmG_TF_2nd,Time[0]) != iBarShift(NULL,enmG_TF_2nd,Time[1]))
      {
         for(int i=2;i<Bars-1;i++)
         if(iBarShift(NULL,enmG_TF_2nd,Time[i])!=iBarShift(NULL,enmG_TF_2nd,Time[i+1]))
         {
            intL_BTC  = i+1;
            //Alert("TF=",strG_TF_1st,"; ",Symbol()," ",enmG_TF_2nd," ",strG_NazwaIndi," Bars To Calculate: ",intL_BTC);
            break;
         }
      }     
   }
   //Lines
   for (int i=0;i<intL_BTC;i++)
   {
      int intL_TTF = iBarShift(NULL,enmG_TF_1st,Time[i]);
      arr_FastLine_TTF[i]= calc_DO_single_line(enmG_TF_1st,enmE_Set_TF_1st,line_fast,intL_TTF);
      arr_SlowLine_TTF[i]= calc_DO_single_line(enmG_TF_1st,enmE_Set_TF_1st,line_slow,intL_TTF);

      int intL_HTF = iBarShift(NULL,enmG_TF_2nd,Time[i]);   
      arr_FastLine_HTF[i]= calc_DO_single_line(enmG_TF_2nd,enmE_Set_TF_2nd,line_fast,intL_HTF);
      arr_SlowLine_HTF[i]= calc_DO_single_line(enmG_TF_2nd,enmE_Set_TF_2nd,line_slow,intL_HTF);
      
      int intL_HHTF = iBarShift(NULL,enmG_TF_3rd,Time[i]);   
      arr_FastLine_HHTF[i]= calc_DO_single_line(enmG_TF_3rd,enmE_Set_TF_3rd,line_fast,intL_HHTF);
      arr_SlowLine_HHTF[i]= calc_DO_single_line(enmG_TF_3rd,enmE_Set_TF_3rd,line_slow,intL_HHTF);
   }
   //Arrows
   calculate_Arrows(intL_BTC);  
   //Alerts
   if(rates_total!=prev_calculated)
   {
      //ogrania odczyty DO
      if(blnE_Display_DO_Readings) manage_Readings();
   }
   //alerty
   manage_Alerts();
//--- return value of prev_calculated for next call
   return(rates_total);
}
////+------------------------------------------------------------------+
bool calculate_Arrows(int head_BTC)
{
   for (int i=0;i<head_BTC;i++)
   {
      arr_BullArrow[i] = 0; arr_BearArrow[i] = 0;

      int intL_HTF  = iBarShift(NULL,enmG_TF_2nd,Time[i]);
      int intL_HHTF = iBarShift(NULL,enmG_TF_3rd,Time[i]);         
      ENUMS_DO_STATE enmL_DO_TTF   = calculate_DO_i(NULL,0,          enmE_Set_TF_1st,i,enmE_ObOs_Line_TF_1st);      
      ENUMS_DO_STATE enmL_DO_HTF   = calculate_DO_i(NULL,enmG_TF_2nd,enmE_Set_TF_2nd,intL_HTF,enmE_ObOs_Line_TF_2nd); 
      ENUMS_DO_STATE enmL_DO_HHTF  = calculate_DO_i(NULL,enmG_TF_3rd,enmE_Set_TF_3rd,intL_HHTF,enmE_ObOs_Line_TF_3rd);      

      if (blnE_Arrows)
      {
         if(blnE_Czy_TF_3rd && blnE_Czy_TF_2nd)
         {
            if(enmL_DO_HHTF == osc_bearOS || enmL_DO_HHTF  == osc_bullRevInOS || enmL_DO_HHTF == osc_bullRev || enmL_DO_HHTF == osc_bull || enmL_DO_HHTF == osc_bullOB) //hhtf nie przeszkadza
            if(enmL_DO_HTF  == osc_bearOS || enmL_DO_HTF   == osc_bullRevInOS || enmL_DO_HTF == osc_bullRev  || enmL_DO_HTF == osc_bull  || enmL_DO_HTF == osc_bullOB)  //htf nie przeszkadza
            if(enmL_DO_TTF  == osc_bearOS || enmL_DO_TTF   == osc_bullRevInOS || enmL_DO_TTF  == osc_bull)                                                              //ttf jakby bullish   
               if (i>0) arr_BullArrow[i] = 20;
            
            if(enmL_DO_HHTF == osc_bullOB || enmL_DO_HHTF  == osc_bearRevInOB || enmL_DO_HHTF == osc_bearRev || enmL_DO_HHTF == osc_bear || enmL_DO_HHTF == osc_bearOS)
            if(enmL_DO_HTF  == osc_bullOB || enmL_DO_HTF   == osc_bearRevInOB || enmL_DO_HTF == osc_bearRev  || enmL_DO_HTF == osc_bear  || enmL_DO_HTF == osc_bearOS)
            if(enmL_DO_TTF  == osc_bullOB || enmL_DO_TTF   == osc_bearRevInOB || enmL_DO_TTF  == osc_bear)
               if (i>0) arr_BearArrow[i] = 80;
         }
         else if(blnE_Czy_TF_2nd)
         {
            if(enmL_DO_HTF  == osc_bearOS || enmL_DO_HTF   == osc_bullRevInOS || enmL_DO_HTF  == osc_bullRev || enmL_DO_HTF  == osc_bull || enmL_DO_HTF  == osc_bullOB)    // HTF nie przeszkadza
            if(enmL_DO_TTF  == osc_bearOS || enmL_DO_TTF   == osc_bullRevInOS || enmL_DO_TTF  == osc_bull)                                                                 // tanio lub wzrostowo na TTF 
               if (i>0) arr_BullArrow[i] = 20;
         
            if(enmL_DO_HTF  == osc_bullOB || enmL_DO_HTF   == osc_bearRevInOB || enmL_DO_HTF  == osc_bearRev || enmL_DO_HTF  == osc_bear || enmL_DO_HTF  == osc_bearOS)    // HTF nie przeszkadza
            if(enmL_DO_TTF  == osc_bullOB || enmL_DO_TTF   == osc_bearRevInOB || enmL_DO_TTF  == osc_bear)                                                                 // drogo lub spadkowo na TTF                                                         // tanio na TTF 
               if (i>0) arr_BearArrow[i] = 80;
         }
         else if(blnE_Czy_TF_3rd)
         {
            if(enmL_DO_HHTF  == osc_bearOS || enmL_DO_HHTF   == osc_bullRevInOS || enmL_DO_HHTF  == osc_bullRev || enmL_DO_HHTF  == osc_bull || enmL_DO_HHTF  == osc_bullOB)  // HTF nie przeszkadza
            if(enmL_DO_TTF   == osc_bearOS || enmL_DO_TTF    == osc_bullRevInOS || enmL_DO_TTF   == osc_bull)                                                                 // tanio lub wzrostowo na TTF 
               if (i>0) arr_BullArrow[i] = 20;
            
            if(enmL_DO_HHTF  == osc_bullOB || enmL_DO_HHTF   == osc_bearRevInOB || enmL_DO_HHTF  == osc_bearRev || enmL_DO_HHTF  == osc_bear || enmL_DO_HHTF  == osc_bearOS)  // HTF nie przeszkadza
            if(enmL_DO_TTF   == osc_bullOB || enmL_DO_TTF    == osc_bearRevInOB || enmL_DO_TTF   == osc_bear)                                                                 // drogo lub spadkowo na TTF                                                         // tanio na TTF 
               if (i>0) arr_BearArrow[i] = 80;
         }
         else
         {
            if(enmL_DO_TTF  == osc_bearOS || enmL_DO_TTF   == osc_bullRevInOS || enmL_DO_TTF  == osc_bull)                                                              //ttf jakby bullish   
               if (i>0) arr_BullArrow[i] = 20;
            if(enmL_DO_TTF  == osc_bullOB || enmL_DO_TTF   == osc_bearRevInOB || enmL_DO_TTF  == osc_bear)
               if (i>0) arr_BearArrow[i] = 80;
         }
      }
   }
   return true;   
}
//+------------------------------------------------------------------+
ENUMS_DO_STATE calculate_DO_i(   string               head_rynek,
                                    ENUM_TIMEFRAMES      head_timeframe,
                                    const int            head_do_set = 1,
                                    const int            head_shift = 1,
                                    const ENUMS_DO_Line  head_ObOs_Line = line_slow)
{
   //
   double dblL_fl, dblL_sl, dblL_fl_1, dblL_sl_1;

   dblL_fl    = iCustom(head_rynek,head_timeframe,"0 Simons DO",head_do_set,0,head_shift);
   dblL_sl    = iCustom(head_rynek,head_timeframe,"0 Simons DO",head_do_set,1,head_shift);
   dblL_fl_1  = iCustom(head_rynek,head_timeframe,"0 Simons DO",head_do_set,0,head_shift+1);
   dblL_sl_1  = iCustom(head_rynek,head_timeframe,"0 Simons DO",head_do_set,1,head_shift+1);
   return read_DO_State(dblL_fl,dblL_sl,dblL_fl_1,dblL_sl_1,head_ObOs_Line);
}
////+------------------------------------------------------------------+
string translate_DO_readings(ENUMS_DO_STATE head_DO_reading)
{

   if(head_DO_reading == osc_bullRevInOS) return "BullRV/OS";
   if(head_DO_reading == osc_bullRev)     return "BullRV";
   if(head_DO_reading == osc_bull)        return "Bull";
   if(head_DO_reading == osc_bullOB)      return "BullOB";
   if(head_DO_reading == osc_bearRevInOB) return "BearRV/OB";
   if(head_DO_reading == osc_bearRev)     return "BearRV";
   if(head_DO_reading == osc_bear)        return "Bear";
   if(head_DO_reading == osc_bearOS)      return "BearOS";
                                          return "---";
}
////+------------------------------------------------------------------+
////+                        Alert Management                          +
////+------------------------------------------------------------------+
bool manage_Alerts()
{
   if(!blnE_Czy_Alerts) return false;
   if(!blnG_Czy_Alerts) return false;

   string strL_Info = Symbol() + " (" + strG_TF_1st + "): " + strG_NazwaIndi + " Says >> ";
   
   if(arr_BullArrow[1] || arr_BullArrow[0]  > 0)
   {
      if(arr_BullArrow[1] == 10) Alert(strL_Info," HTF/HHTF BUY");
      else                       Alert(strL_Info," TTF+ BUY");
      blnG_Czy_Alerts = false;
      return true;
   }
   if(arr_BearArrow[1] > 0 || arr_BearArrow[0] > 0)
   {
      if(arr_BearArrow[1] == 90) Alert(strL_Info," HTF/HHTF SELL");
      else                       Alert(strL_Info," TTF+ SELL");
      blnG_Czy_Alerts = false;
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+ 
//| --- Dynamic Oscillator Readings on the Screen ---                | 
//+------------------------------------------------------------------+ 
bool show_Readings()
{
   if(!blnE_Display_DO_Readings) return false;  //jak nie to nie
   //ustawienia zmiennych
   
   intG_WinIdx=WindowFind(strG_NazwaIndi);      //dla pewności 
   int intL_X = intU_X,  intL_Y = 20;               
   int intL_H = 20;                             //wysokość cienia
   
   if (check_dif_DO_set_4_display(enmG_TF_1st,enmE_Set_TF_1st,enmG_TF_2nd,enmE_Set_TF_2nd)) intL_H = 33;   //wysokość cienia w trzech wariantach
   if (check_dif_DO_set_4_display(enmG_TF_2nd,enmE_Set_TF_2nd,enmG_TF_3rd,enmE_Set_TF_3rd)) intL_H = 45;

   color clrL_Shade = ChartGetInteger(ChartID(),CHART_COLOR_BACKGROUND); //cień w kolorze tła
   
   //kasowanie poprzednich wynków
   delete_Readings();
   
   //tworzenie nowych
   create_RectLabel (ChartID(),strG_Shade_Readings,intG_WinIdx,intL_X,intL_Y,144,intL_H,clrL_Shade,1,CORNER_LEFT_UPPER);
   intL_Y = intL_Y + 4; //leciutki margines
   
   //markuje readingi
   //create_Label(ChartID(),strG_Readings_TTF_1,  intG_WinIdx,intL_X+6,intL_Y+13*1, CORNER_LEFT_UPPER,"Rea1","Arial",8);
   //if(check_dif_DO_set_4_display(enmG_TF_1st,enmE_Set_TF_1st,enmG_TF_2nd,enmE_Set_TF_2nd))create_Label(ChartID(),strG_Readings_HTF_1,  intG_WinIdx,intL_X+6,intL_Y+13*2, CORNER_LEFT_UPPER,"Rea2","Arial",8);
   //if(check_dif_DO_set_4_display(enmG_TF_2nd,enmE_Set_TF_2nd,enmG_TF_3rd,enmE_Set_TF_3rd))create_Label(ChartID(),strG_Readings_HTF_2,  intG_WinIdx,intL_X+6,intL_Y+13*3, CORNER_LEFT_UPPER,"Rea3","Arial",8);
   
   //markuje readingi
   if (blnE_Czy_TF_1st) create_Label(ChartID(),strG_Readings_TTF_1,  intG_WinIdx,intL_X+6,intL_Y+13*1, CORNER_LEFT_UPPER,"Rea1","Arial",8);
   if (blnE_Czy_TF_2nd) create_Label(ChartID(),strG_Readings_HTF_1,  intG_WinIdx,intL_X+6,intL_Y+13*2, CORNER_LEFT_UPPER,"Rea2","Arial",8);
   if (blnE_Czy_TF_3rd) create_Label(ChartID(),strG_Readings_HTF_2,  intG_WinIdx,intL_X+6,intL_Y+13*3, CORNER_LEFT_UPPER,"Rea3","Arial",8);
   
   return true;
}
//+------------------------------------------------------------------+
bool manage_Readings()
{
   //abstrakt 20180905
   if(!blnE_Display_DO_Readings) return false;
   //wartości odczytów
   calc_Readings(1); calc_Readings(2); calc_Readings(3);
   //długość cienia
   int intL_StringLen = calculate_Shadow_Len(strG_Readings_TTF_1,strG_Readings_HTF_1,strG_Readings_HTF_2);
   ObjectSetInteger(ChartID(),strG_Shade_Readings,OBJPROP_XSIZE,intL_StringLen);
   //
   return true;
}
//+------------------------------------------------------------------+
bool calc_Readings(int head_level)
{
   ENUM_TIMEFRAMES   enmL_TimeFrame = 0;
   ENUMS_DO_SET      enmL_DO_Set    = 1;
   string            strL_TF        = "";

   if(head_level == 1)
   {
      enmL_TimeFrame = enmG_TF_1st;
      enmL_DO_Set = enmE_Set_TF_1st;
      strL_TF = strG_TF_1st;
   }
   if(head_level == 2)
   {
      enmL_TimeFrame = enmG_TF_2nd;
      strL_TF = strG_TF_2nd;
      enmL_DO_Set = enmE_Set_TF_2nd;
   }
   if(head_level == 3)
   {
      enmL_TimeFrame = enmG_TF_3rd;
      strL_TF = strG_TF_3rd;
      enmL_DO_Set = enmE_Set_TF_3rd;      
   }

   ENUMS_DO_STATE enmL_DO_0   = calculate_DO_i(NULL,enmL_TimeFrame,enmL_DO_Set,0);      
   ENUMS_DO_STATE enmL_DO_1   = calculate_DO_i(NULL,enmL_TimeFrame,enmL_DO_Set,1);

   string strL_DO_state_0 = translate_DO_readings(enmL_DO_0);
   string strL_DO_state_1 = translate_DO_readings(enmL_DO_1);
    
   string strL_Text = strL_TF  + "(" + translate_DO_settings(enmL_DO_Set)+"): " + strL_DO_state_1;      
   
   if(strL_DO_state_0!=strL_DO_state_1)
   {
      strL_Text = strL_Text + " (>" + strL_DO_state_0+")";;
   }
   
   color  clrL_DO_color = color_DO_Readings(strL_DO_state_1);
   string strL_DO_font  = font_DO_Readings(strL_DO_state_1);   

   if(head_level == 1)
   {
      ObjectSetString(ChartID(), strG_Readings_TTF_1, OBJPROP_TEXT, strL_Text);
      ObjectSetInteger(ChartID(),strG_Readings_TTF_1, OBJPROP_COLOR,clrL_DO_color);
      ObjectSetString(ChartID(), strG_Readings_TTF_1, OBJPROP_FONT, strL_DO_font);
   }
   if(head_level == 2)
   {
      ObjectSetString(ChartID(), strG_Readings_HTF_1, OBJPROP_TEXT, strL_Text);
      ObjectSetInteger(ChartID(),strG_Readings_HTF_1, OBJPROP_COLOR,clrL_DO_color);
      ObjectSetString(ChartID(), strG_Readings_HTF_1, OBJPROP_FONT, strL_DO_font);
   }
   if(head_level == 3)
   {
      ObjectSetString(ChartID(), strG_Readings_HTF_2, OBJPROP_TEXT, strL_Text);
      ObjectSetInteger(ChartID(),strG_Readings_HTF_2, OBJPROP_COLOR,clrL_DO_color);
      ObjectSetString(ChartID(), strG_Readings_HTF_2, OBJPROP_FONT, strL_DO_font);
   }
      
   return true;
}
//+------------------------------------------------------------------+
bool delete_Readings()
{
   if(ObjectFind(ChartID(),strG_Shade_Readings) >-1)  ObjectDelete(ChartID(),strG_Shade_Readings);
   if(ObjectFind(ChartID(),strG_Readings_TTF_1) >-1)  ObjectDelete(ChartID(),strG_Readings_TTF_1);
   if(ObjectFind(ChartID(),strG_Readings_HTF_1) >-1)  ObjectDelete(ChartID(),strG_Readings_HTF_1);
   if(ObjectFind(ChartID(),strG_Readings_HTF_2) >-1)  ObjectDelete(ChartID(),strG_Readings_HTF_2);
   return true;
}