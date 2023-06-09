//+------------------------------------------------------------------+
//|                                           0 Simons Viper 3.0.mq4 |
//|                                  Copyright 2018, SzymonMarek.com |
//|                                      https://www.SzymonMarek.com |
//+------------------------------------------------------------------+
//20181201 ostatnie zmiany
#property copyright "Copyright 2015-2018, SzymonMarek.com"
#property link      "https://www.SzymonMarek.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property description "Simon's Viper. Inspirowany przez Aligatora Billa Williamsa i Średnie Kroczące Joe Di Napolego. Ustawienia tych autorów dostępne również jako opcja w ramach tego narzędzia."
#property description " "
#property description "Viper climbs a bamboo tree."

//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
#property indicator_buffers 8
double arr_0[], arr_1[], arr_2[], arr_3[];
double arr_4[], arr_5[], arr_6[], arr_7[];
//+------------------------------------------------------------------+
enum ENUMS_Viper
{
   viper_Classic,
   viper_Simons_free_lines,
   viper_Simons_5x0_5x1_20x0_three_lines,
   viper_Classic_Plus,
   viper_Slower,
   viper_Rainbow,
   viper_Rainbow_2,
   viper_Simons_2x2_10_18_29x11,
   viper_7x4,
   viper_4_m1,
   viper_DEMA_20x40,   
   viper_Tens,
   viper_13ns,
   viper_Simons_Great_Line,
   viper_DiLines,
   viper_Alligatgor
};
//+------------------------------------------------------------------+
//globalne zmienne
//+------------------------------------------------------------------+
long lngG_ID = ChartID();                    //chart ID
string strG_Viper = "Vi";                    //nazwa Buttona
string strG_V_desc = "Vi_Desc";              //nazwa opisu
string strG_Shade_V_desc = "Vi desc shade";  //opis cienia1
ENUM_APPLIED_PRICE enmG_Price;
int intG_0_Val, intG_0_Shift; ENUM_MA_METHOD enmG_0_Method; int intG_0_IdxStyle = DRAW_HISTOGRAM;  ENUM_LINE_STYLE enmG_0_LineStyle; int intG_0_Width;  color clrG_0;
int intG_1_Val, intG_1_Shift; ENUM_MA_METHOD enmG_1_Method; int intG_1_IdxStyle = DRAW_HISTOGRAM;  ENUM_LINE_STYLE enmG_1_LineStyle; int intG_1_Width;  color clrG_1;
int intG_2_Val, intG_2_Shift; ENUM_MA_METHOD enmG_2_Method; int intG_2_IdxStyle = DRAW_HISTOGRAM;  ENUM_LINE_STYLE enmG_2_LineStyle; int intG_2_Width;  color clrG_2;
int intG_3_Val, intG_3_Shift; ENUM_MA_METHOD enmG_3_Method; int intG_3_IdxStyle = DRAW_HISTOGRAM;  ENUM_LINE_STYLE enmG_3_LineStyle; int intG_3_Width;  color clrG_3;
int intG_4_Val, intG_4_Shift; ENUM_MA_METHOD enmG_4_Method; int intG_4_IdxStyle = DRAW_HISTOGRAM;  ENUM_LINE_STYLE enmG_4_LineStyle; int intG_4_Width;  color clrG_4;
int intG_5_Val, intG_5_Shift; ENUM_MA_METHOD enmG_5_Method; int intG_5_IdxStyle = DRAW_HISTOGRAM;  ENUM_LINE_STYLE enmG_5_LineStyle; int intG_5_Width;  color clrG_5;
int intG_6_Val, intG_6_Shift; ENUM_MA_METHOD enmG_6_Method; int intG_6_IdxStyle = DRAW_HISTOGRAM;  ENUM_LINE_STYLE enmG_6_LineStyle; int intG_6_Width;  color clrG_6;
int intG_7_Val, intG_7_Shift; ENUM_MA_METHOD enmG_7_Method; int intG_7_IdxStyle = DRAW_HISTOGRAM;  ENUM_LINE_STYLE enmG_7_LineStyle; int intG_7_Width;  color clrG_7;
//+------------------------------------------------------------------+
//globalne zewnętrzne
//+------------------------------------------------------------------+
extern string           s3 = "--- Rodzaj Vipera---";                       //---
extern ENUMS_Viper      enmE_Viper_Type               = viper_Simons_free_lines;
extern string           s0 = "--- Widoczność Oscylatora na Wykresie ---";  //---
extern bool             blnE_Czy_Widoczny             = true;
extern string           s10 = "--- Widoczność Znaków Zmian Tendencji ---"; //---
extern bool             blnE_Czy_ZnakZmianyKierunku   = false;
extern string           s11 = "--- Opis na ekranie  ---"; //---
extern bool             blnE_Czy_OpisNaEkranie        = false;
extern ENUM_TIMEFRAMES  enmE_TF_Vipers_TF             = PERIOD_CURRENT;
extern string           s4 = "--- Gdy Free Lines ---";                       //---
extern int              intE_L1                       = 5;
extern int              itnE_L1_shift                 = 1;
extern ENUM_MA_METHOD   enmE_L1_methd                 = MODE_SMA;      
extern int              intE_L2                       = 20;
extern int              itnE_L2_shift                 = 0;
extern ENUM_MA_METHOD   enmE_L2_methd                 = MODE_SMA;
extern string           s2 = "-- Widoczność Linii na Wykresie----";        //---
extern bool             blnE_Czy_0                    = true;
extern bool             blnE_Czy_1                    = true;
extern bool             blnE_Czy_2                    = true;
extern bool             blnE_Czy_3                    = true;
extern bool             blnE_Czy_4                    = true;
extern bool             blnE_Czy_5                    = true;
extern bool             blnE_Czy_6                    = true;
extern bool             blnE_Czy_7                    = true;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   if(enmE_TF_Vipers_TF == PERIOD_CURRENT) enmE_TF_Vipers_TF = Period();
   
   IndicatorDigits(Digits());   

   intG_0_IdxStyle = DRAW_NONE;   
   intG_1_IdxStyle = DRAW_NONE;   
   intG_2_IdxStyle = DRAW_NONE;
   intG_3_IdxStyle = DRAW_NONE;
   intG_4_IdxStyle = DRAW_NONE;
   intG_5_IdxStyle = DRAW_NONE;
   intG_6_IdxStyle = DRAW_NONE;
   intG_7_IdxStyle = DRAW_NONE;

   enmG_Price = PRICE_MEDIAN;
   
   switch(enmE_Viper_Type) 
   {
   case viper_Simons_5x0_5x1_20x0_three_lines:
      IndicatorShortName("Viper's Weekly Trend");
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;     intG_0_Width = 1;   clrG_0 = clrLime;        intG_0_Val = 05;  intG_0_Shift = 00; enmG_0_Method = MODE_SMA; SetIndexShift(0,intG_0_Shift); SetIndexLabel(0,translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);      
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;     intG_1_Width = 1;   clrG_1 = clrLime;        intG_1_Val = 05;  intG_1_Shift = 01; enmG_1_Method = MODE_SMA; SetIndexShift(1,intG_1_Shift); SetIndexLabel(1,translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);      
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;     intG_2_Width = 1;   clrG_2 = clrRed;         intG_2_Val = 20;  intG_2_Shift = 00; enmG_2_Method = MODE_SMA; SetIndexShift(2,intG_2_Shift); SetIndexLabel(2,translate_MA_type(enmG_2_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);
      break;   
   case viper_Simons_2x2_10_18_29x11:
      IndicatorShortName("Viper's Newly Modified Trend");
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_DOT;     intG_0_Width = 1;   clrG_0 = clrMagenta;     intG_0_Val = 02; intG_0_Shift = 02; enmG_0_Method = MODE_SMMA;SetIndexShift(0,intG_0_Shift); SetIndexLabel(0,translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);      
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_DOT;     intG_1_Width = 1;   clrG_1 = clrLime;        intG_1_Val = 10; intG_1_Shift = 00; enmG_1_Method = MODE_SMA; SetIndexShift(1,intG_0_Shift); SetIndexLabel(1,translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);      
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;     intG_2_Width = 1;   clrG_2 = clrRed;         intG_2_Val = 18; intG_2_Shift = 00; enmG_2_Method = MODE_SMA; SetIndexShift(2,intG_1_Shift); SetIndexLabel(2,translate_MA_type(enmG_2_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);
      intG_3_IdxStyle = DRAW_LINE;  enmG_3_LineStyle = STYLE_SOLID;     intG_3_Width = 1;   clrG_3 = clrRoyalBlue;   intG_3_Val = 29; intG_3_Shift = 11; enmG_3_Method = MODE_EMA; SetIndexShift(3,intG_2_Shift); SetIndexLabel(3,"Tale: " +translate_MA_type(enmG_3_Method)+"("+IntegerToString(intG_3_Val)+"x"+IntegerToString(intG_3_Shift)+")");SetIndexEmptyValue(3,0.0);    
      break;      
   case viper_Simons_Great_Line:
      IndicatorShortName("Viper's Base Trend");
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;     intG_0_Width = 2;   clrG_0 = clrAqua;        intG_0_Val = 02; intG_0_Shift = 01; enmG_0_Method = MODE_SMMA; SetIndexShift(0,intG_0_Shift); SetIndexLabel(0,translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);      
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;     intG_1_Width = 2;   clrG_1 = clrMagenta;        intG_1_Val = 03; intG_1_Shift = 03; enmG_1_Method = MODE_SMMA; SetIndexShift(1,intG_1_Shift); SetIndexLabel(1,translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      //intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;     intG_2_Width = 3;   clrG_2 = clrRoyalBlue;   intG_2_Val = 29; intG_2_Shift = 11; enmG_2_Method = MODE_EMA;  SetIndexShift(2,intG_2_Shift); SetIndexLabel(2,"Tale: " +translate_MA_type(enmG_2_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);      
      break;   
   case viper_Simons_free_lines:
      IndicatorShortName("Viper's Free User Lines");
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;     intG_0_Width = 1;   clrG_0 = clrLime;  intG_0_Val = intE_L1; intG_0_Shift = itnE_L1_shift; enmG_0_Method = enmE_L1_methd; SetIndexShift(0,intG_0_Shift); SetIndexLabel(0,translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);      
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;     intG_1_Width = 1;   clrG_1 = clrRed;   intG_1_Val = intE_L2; intG_1_Shift = itnE_L2_shift; enmG_1_Method = enmE_L2_methd; SetIndexShift(1,intG_1_Shift); SetIndexLabel(1,translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      //intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;     intG_2_Width = 3;   clrG_2 = clrRoyalBlue;   intG_2_Val = 29; intG_2_Shift = 11; enmG_2_Method = MODE_EMA;  SetIndexShift(2,intG_2_Shift); SetIndexLabel(2,"Tale: " +translate_MA_type(enmG_2_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);      
      break;         
   case viper_DEMA_20x40:
      IndicatorShortName("Viper's countertrend search. Quite OK for smaller Time Frames (i.e. m1)");
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;     intG_0_Width = 2;   clrG_0 = clrLime;        SetIndexLabel(0,"DMA"+IntegerToString(20)+"x0");SetIndexShift(0,0);
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_DASHDOT;   intG_1_Width = 1;   clrG_1 = clrGold;        SetIndexLabel(1,"SMA"+IntegerToString(20)+"x0");SetIndexShift(1,0);
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;     intG_2_Width = 2;   clrG_2 = clrRed;         SetIndexLabel(2,"DMA"+IntegerToString(40)+"x0");SetIndexShift(2,0);
      intG_3_IdxStyle = DRAW_LINE;  enmG_3_LineStyle = STYLE_SOLID;     intG_3_Width = 2;   clrG_3 = clrRoyalBlue;   SetIndexLabel(3,"DMA"+IntegerToString(80)+"x0");SetIndexShift(3,0);
      //intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_DOT;       intG_2_Width = 2;   clrG_2 = clrLime; SetIndexLabel(2,"DMA 39");SetIndexShift(2,0);
      break;
   case viper_7x4:
      IndicatorShortName("Viper's looking for a Steep Trend");
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_DOT;       intG_0_Width = 1;   clrG_0 = clrGold;     intG_0_Val = 07; intG_0_Shift = 0;  enmG_0_Method = MODE_SMA; SetIndexShift(0,intG_0_Shift); SetIndexLabel(0,translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_DASHDOTDOT;intG_1_Width = 1;   clrG_1 = clrGold;     intG_1_Val = 07; intG_1_Shift = 1;  enmG_1_Method = MODE_SMA; SetIndexShift(1,intG_1_Shift); SetIndexLabel(1,translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_DASHDOT;   intG_2_Width = 1;   clrG_2 = clrGold;     intG_2_Val = 07; intG_2_Shift = 2;  enmG_2_Method = MODE_SMA; SetIndexShift(2,intG_2_Shift); SetIndexLabel(2,translate_MA_type(enmG_2_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);
      intG_3_IdxStyle = DRAW_LINE;  enmG_3_LineStyle = STYLE_SOLID;     intG_3_Width = 1;   clrG_3 = clrGold;     intG_3_Val = 07; intG_3_Shift = 3;  enmG_3_Method = MODE_SMA; SetIndexShift(3,intG_3_Shift); SetIndexLabel(3,translate_MA_type(enmG_3_Method)+"("+IntegerToString(intG_3_Val)+"x"+IntegerToString(intG_3_Shift)+")");SetIndexEmptyValue(3,0.0);
      intG_4_IdxStyle = DRAW_LINE;  enmG_4_LineStyle = STYLE_SOLID;     intG_4_Width = 2;   clrG_4 = clrRed;      intG_4_Val = 29; intG_4_Shift = 0;  enmG_4_Method = MODE_EMA; SetIndexShift(4,intG_4_Shift); SetIndexLabel(4,translate_MA_type(enmG_4_Method)+"("+IntegerToString(intG_4_Val)+"x"+IntegerToString(intG_4_Shift)+")");SetIndexEmptyValue(4,0.0);
      intG_5_IdxStyle = DRAW_LINE;  enmG_5_LineStyle = STYLE_SOLID;     intG_5_Width = 3;   clrG_5 = clrRoyalBlue;intG_5_Val = 29; intG_5_Shift = 11; enmG_5_Method = MODE_EMA; SetIndexShift(5,intG_5_Shift); SetIndexLabel(5,"Tale: " +translate_MA_type(enmG_5_Method)+"("+IntegerToString(intG_5_Val)+"x"+IntegerToString(intG_5_Shift)+")");SetIndexEmptyValue(5,0.0);
      intG_6_IdxStyle = DRAW_ARROW; enmG_6_LineStyle = STYLE_SOLID;     intG_6_Width = 5;   clrG_6 = clrLime;     SetIndexShift(6,0); SetIndexEmptyValue(6,0.0); SetIndexArrow(6,174);SetIndexLabel(6,"Bullish Rev");
      intG_7_IdxStyle = DRAW_ARROW; enmG_7_LineStyle = STYLE_SOLID;     intG_7_Width = 5;   clrG_7 = clrRed;      SetIndexShift(7,0); SetIndexEmptyValue(7,0.0); SetIndexArrow(7,174);SetIndexLabel(7,"Bearish Rev");
      break;
   case viper_4_m1:
      IndicatorShortName("Viper's used on m1 and works nice");
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;  intG_1_Width = 2;   clrG_1 = clrRed;      intG_1_Val = 29; intG_1_Shift = 0;  enmG_1_Method = MODE_EMA; SetIndexShift(1,intG_1_Shift); SetIndexLabel(1,translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;  intG_2_Width = 3;   clrG_2 = clrRoyalBlue;intG_2_Val = 29; intG_2_Shift = 18; enmG_2_Method = MODE_EMA; SetIndexShift(2,intG_2_Shift); SetIndexLabel(2,translate_MA_type(enmG_2_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);
      break;      
   case viper_Classic:
      IndicatorShortName("Classic Viper");
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;  intG_0_Width = 1;   clrG_0 = clrLime;     intG_0_Val = 11; intG_0_Shift = 0;  enmG_0_Method = MODE_EMA; SetIndexShift(0,intG_0_Shift); SetIndexLabel(0,"Fang: " +translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;  intG_1_Width = 1;   clrG_1 = clrRed;      intG_1_Val = 29; intG_1_Shift = 0;  enmG_1_Method = MODE_EMA; SetIndexShift(1,intG_1_Shift); SetIndexLabel(1,"Belly: "+translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;  intG_2_Width = 2;   clrG_2 = clrRoyalBlue;intG_2_Val = 29; intG_2_Shift = 11; enmG_2_Method = MODE_EMA; SetIndexShift(2,intG_2_Shift); SetIndexLabel(2,"Tale: " +translate_MA_type(enmG_2_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);
      intG_3_IdxStyle = DRAW_ARROW; enmG_3_LineStyle = STYLE_SOLID;  intG_3_Width = 1;   clrG_3 = clrLime;     SetIndexShift(3,0); SetIndexEmptyValue(3,0.0); SetIndexArrow(3,174);SetIndexLabel(3,"Bullish Rev");
      intG_4_IdxStyle = DRAW_ARROW; enmG_4_LineStyle = STYLE_SOLID;  intG_4_Width = 1;   clrG_4 = clrRed;      SetIndexShift(4,0); SetIndexEmptyValue(4,0.0); SetIndexArrow(4,174);SetIndexLabel(4,"Bearish Rev");
      break;
   case viper_Classic_Plus:
      IndicatorShortName("Classic Viper Plus");
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;  intG_0_Width = 1;   enmG_0_LineStyle = STYLE_DOT;     clrG_0 = clrLime;     intG_0_Val = 11; intG_0_Shift = 0;  enmG_0_Method = MODE_EMA; SetIndexShift(0,intG_0_Shift); SetIndexLabel(0,"Fang: " +translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;  intG_1_Width = 1;   enmG_1_LineStyle = STYLE_DOT;     clrG_1 = clrRed;      intG_1_Val = 18; intG_1_Shift = 0;  enmG_1_Method = MODE_EMA; SetIndexShift(1,intG_1_Shift); SetIndexLabel(1,"Belly: "+translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;  intG_2_Width = 1;   enmG_2_LineStyle = STYLE_DOT;     clrG_2 = clrRoyalBlue;intG_2_Val = 29; intG_2_Shift = 0;  enmG_2_Method = MODE_EMA; SetIndexShift(2,intG_2_Shift); SetIndexLabel(2,"Tale: " +translate_MA_type(enmG_2_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);
      intG_3_IdxStyle = DRAW_LINE;  enmG_3_LineStyle = STYLE_SOLID;  intG_3_Width = 2;   enmG_3_LineStyle = STYLE_SOLID;   clrG_3 = clrRoyalBlue;intG_3_Val = 29; intG_3_Shift = 11; enmG_3_Method = MODE_EMA; SetIndexShift(3,intG_3_Shift); SetIndexLabel(3,"Tale: " +translate_MA_type(enmG_3_Method)+"("+IntegerToString(intG_3_Val)+"x"+IntegerToString(intG_3_Shift)+")");SetIndexEmptyValue(3,0.0);
      break;
   case viper_Slower:
      IndicatorShortName("Slower Viper");
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;  intG_0_Width = 1;   clrG_0 = clrLime;     intG_0_Val = 11; intG_0_Shift = 0;  enmG_0_Method = MODE_EMA; SetIndexShift(0,intG_0_Shift); SetIndexLabel(0,"Fang: " +translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;  intG_1_Width = 1;   clrG_1 = clrRed;      intG_1_Val = 29; intG_1_Shift = 0;  enmG_1_Method = MODE_EMA; SetIndexShift(1,intG_1_Shift); SetIndexLabel(1,"Belly: "+translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;  intG_2_Width = 2;   clrG_2 = clrRoyalBlue;intG_2_Val = 29; intG_2_Shift = 18; enmG_2_Method = MODE_EMA; SetIndexShift(2,intG_2_Shift); SetIndexLabel(2,"Tale: " +translate_MA_type(enmG_2_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);
      intG_3_IdxStyle = DRAW_ARROW; enmG_3_LineStyle = STYLE_SOLID;  intG_3_Width = 1;   clrG_3 = clrLime;     SetIndexShift(3,0); SetIndexArrow(3,174);SetIndexLabel(3,"Bullish Rev");SetIndexEmptyValue(3,0.0);
      intG_4_IdxStyle = DRAW_ARROW; enmG_4_LineStyle = STYLE_SOLID;  intG_4_Width = 1;   clrG_4 = clrRed;      SetIndexShift(4,0); SetIndexArrow(4,174);SetIndexLabel(4,"Bearish Rev");SetIndexEmptyValue(4,0.0); 
      break;
   case viper_Tens:
      IndicatorShortName("Tens");
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;  intG_0_Width = 2;   clrG_0 = clrLime;     intG_0_Val = 10;  intG_0_Shift = 0;  enmG_0_Method = MODE_SMA; SetIndexShift(0,intG_0_Shift); SetIndexLabel(0,translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;  intG_1_Width = 2;   clrG_1 = clrRed;      intG_1_Val = 20;  intG_1_Shift = 0;  enmG_1_Method = MODE_SMA; SetIndexShift(1,intG_1_Shift); SetIndexLabel(1,translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;  intG_2_Width = 2;   clrG_2 = clrRoyalBlue;intG_2_Val = 50;  intG_2_Shift = 0;  enmG_2_Method = MODE_SMA; SetIndexShift(2,intG_2_Shift); SetIndexLabel(2,translate_MA_type(enmG_2_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);
      //intG_3_IdxStyle = DRAW_LINE;  enmG_3_LineStyle = STYLE_SOLID;  intG_3_Width = 1;   clrG_3 = clrRoyalBlue;intG_3_Val = 250; intG_2_Shift = 0;  enmG_3_Method = MODE_SMA; SetIndexShift(3,intG_3_Shift); SetIndexLabel(3,translate_MA_type(enmG_3_Method)+"("+IntegerToString(intG_3_Val)+"x"+IntegerToString(intG_3_Shift)+")");SetIndexEmptyValue(3,0.0);
      break;
   case viper_13ns:
      IndicatorShortName("Thirteens");
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;  intG_0_Width = 2;   clrG_0 = clrLime;     intG_0_Val = 13;  intG_0_Shift = 0;  enmG_0_Method = MODE_SMA; SetIndexShift(0,intG_0_Shift); SetIndexLabel(0,translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;  intG_1_Width = 2;   clrG_1 = clrRed;      intG_1_Val = 52;  intG_1_Shift = 0;  enmG_1_Method = MODE_SMA; SetIndexShift(1,intG_1_Shift); SetIndexLabel(1,translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      break;      
   case viper_DiLines:
      IndicatorShortName("Trend by Di Napoli");
      //ienmG_Price = PRICE_CLOSE;
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;  intG_0_Width = 4;clrG_0 = clrGold;     intG_0_Val = 03; intG_0_Shift = 3;  enmG_0_Method = MODE_SMA; SetIndexShift(0,intG_0_Shift); SetIndexLabel(0, translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;  intG_1_Width = 4;clrG_1 = clrRed;      intG_1_Val = 07; intG_1_Shift = 5;  enmG_1_Method = MODE_SMA; SetIndexShift(1,intG_1_Shift); SetIndexLabel(1, translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;  intG_2_Width = 4;clrG_2 = clrRoyalBlue;intG_2_Val = 25; intG_2_Shift = 5;  enmG_2_Method = MODE_SMA; SetIndexShift(2,intG_2_Shift); SetIndexLabel(2, translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);
      break;
   case viper_Alligatgor:
      IndicatorShortName("Trend by Bill Williams");   
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;  intG_0_Width = 1;clrG_0 = clrLime;     intG_0_Val = 05; intG_0_Shift = 3;  enmG_0_Method = MODE_SMMA; SetIndexShift(0,intG_0_Shift); SetIndexLabel(0, "Lips: " +translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;  intG_1_Width = 1;clrG_1 = clrRed;      intG_1_Val = 08; intG_1_Shift = 5;  enmG_1_Method = MODE_SMMA; SetIndexShift(1,intG_1_Shift); SetIndexLabel(1, "Teeth: "+translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;  intG_2_Width = 1;clrG_2 = clrRoyalBlue;intG_2_Val = 13; intG_2_Shift = 8;  enmG_2_Method = MODE_SMMA; SetIndexShift(2,intG_2_Shift); SetIndexLabel(2, "Jaw: "  +translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);
      break;   
   case viper_Rainbow:
      IndicatorShortName("Rainbow Trend");      
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;  intG_0_Width = 1;   clrG_0 = clrGold;        intG_0_Val = 04; intG_0_Shift = 3;  enmG_0_Method = MODE_EMA;  SetIndexShift(0,intG_0_Shift);SetIndexLabel(0, translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;  intG_1_Width = 1;   clrG_1 = clrLime;        intG_1_Val = 07; intG_1_Shift = 4;  enmG_1_Method = MODE_EMA;  SetIndexShift(1,intG_1_Shift);SetIndexLabel(1, translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;  intG_2_Width = 1;   clrG_2 = clrRed;         intG_2_Val = 11; intG_2_Shift = 7;  enmG_2_Method = MODE_EMA;  SetIndexShift(2,intG_2_Shift);SetIndexLabel(2, translate_MA_type(enmG_2_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);
      intG_3_IdxStyle = DRAW_LINE;  enmG_3_LineStyle = STYLE_SOLID;  intG_3_Width = 1;   clrG_3 = clrAqua;        intG_3_Val = 18; intG_3_Shift = 11; enmG_3_Method = MODE_EMA;  SetIndexShift(3,intG_3_Shift);SetIndexLabel(3, translate_MA_type(enmG_3_Method)+"("+IntegerToString(intG_3_Val)+"x"+IntegerToString(intG_3_Shift)+")");SetIndexEmptyValue(3,0.0);
      intG_4_IdxStyle = DRAW_LINE;  enmG_4_LineStyle = STYLE_SOLID;  intG_4_Width = 1;   clrG_4 = clrRoyalBlue;   intG_4_Val = 29; intG_4_Shift = 18; enmG_4_Method = MODE_EMA;  SetIndexShift(4,intG_4_Shift);SetIndexLabel(4, translate_MA_type(enmG_4_Method)+"("+IntegerToString(intG_4_Val)+"x"+IntegerToString(intG_4_Shift)+")");SetIndexEmptyValue(4,0.0);
      intG_5_IdxStyle = DRAW_LINE;  enmG_5_LineStyle = STYLE_SOLID;  intG_5_Width = 4;   clrG_5 = clrViolet;      intG_5_Val = 47; intG_5_Shift = 29; enmG_5_Method = MODE_EMA;  SetIndexShift(5,intG_5_Shift);SetIndexLabel(5, translate_MA_type(enmG_5_Method)+"("+IntegerToString(intG_5_Val)+"x"+IntegerToString(intG_5_Shift)+")");SetIndexEmptyValue(5,0.0);
      intG_6_IdxStyle = DRAW_LINE;  enmG_6_LineStyle = STYLE_SOLID;  intG_6_Width = 1;   clrG_6 = clrDarkViolet;  intG_6_Val = 76; intG_6_Shift = 47; enmG_6_Method = MODE_EMA;  SetIndexShift(6,intG_6_Shift);SetIndexLabel(6, translate_MA_type(enmG_6_Method)+"("+IntegerToString(intG_6_Val)+"x"+IntegerToString(intG_6_Shift)+")");SetIndexEmptyValue(6,0.0);
      intG_7_IdxStyle = DRAW_LINE;  enmG_7_LineStyle = STYLE_SOLID;  intG_7_Width = 1;   clrG_7 = clrDarkOrchid;  intG_7_Val = 123;intG_7_Shift = 76; enmG_7_Method = MODE_EMA;  SetIndexShift(7,intG_7_Shift);SetIndexLabel(7, translate_MA_type(enmG_7_Method)+"("+IntegerToString(intG_7_Val)+"x"+IntegerToString(intG_7_Shift)+")");SetIndexEmptyValue(7,0.0);
      break;
   case viper_Rainbow_2:
      IndicatorShortName("Rainbow Trend");      
      intG_0_IdxStyle = DRAW_LINE;  enmG_0_LineStyle = STYLE_SOLID;  intG_0_Width = 1;   clrG_0 = clrGold;        intG_0_Val = 04; intG_0_Shift = 0; enmG_0_Method = MODE_EMA;  SetIndexShift(0,intG_0_Shift);SetIndexLabel(0, translate_MA_type(enmG_0_Method)+"("+IntegerToString(intG_0_Val)+"x"+IntegerToString(intG_0_Shift)+")");SetIndexEmptyValue(0,0.0);
      intG_1_IdxStyle = DRAW_LINE;  enmG_1_LineStyle = STYLE_SOLID;  intG_1_Width = 1;   clrG_1 = clrLime;        intG_1_Val = 07; intG_1_Shift = 0; enmG_1_Method = MODE_EMA;  SetIndexShift(1,intG_1_Shift);SetIndexLabel(1, translate_MA_type(enmG_1_Method)+"("+IntegerToString(intG_1_Val)+"x"+IntegerToString(intG_1_Shift)+")");SetIndexEmptyValue(1,0.0);
      intG_2_IdxStyle = DRAW_LINE;  enmG_2_LineStyle = STYLE_SOLID;  intG_2_Width = 1;   clrG_2 = clrRed;         intG_2_Val = 11; intG_2_Shift = 0; enmG_2_Method = MODE_EMA;  SetIndexShift(2,intG_2_Shift);SetIndexLabel(2, translate_MA_type(enmG_2_Method)+"("+IntegerToString(intG_2_Val)+"x"+IntegerToString(intG_2_Shift)+")");SetIndexEmptyValue(2,0.0);
      intG_3_IdxStyle = DRAW_LINE;  enmG_3_LineStyle = STYLE_SOLID;  intG_3_Width = 1;   clrG_3 = clrAqua;        intG_3_Val = 18; intG_3_Shift = 0; enmG_3_Method = MODE_EMA;  SetIndexShift(3,intG_3_Shift);SetIndexLabel(3, translate_MA_type(enmG_3_Method)+"("+IntegerToString(intG_3_Val)+"x"+IntegerToString(intG_3_Shift)+")");SetIndexEmptyValue(3,0.0);
      intG_4_IdxStyle = DRAW_LINE;  enmG_4_LineStyle = STYLE_SOLID;  intG_4_Width = 1;   clrG_4 = clrRoyalBlue;   intG_4_Val = 29; intG_4_Shift = 0; enmG_4_Method = MODE_EMA;  SetIndexShift(4,intG_4_Shift);SetIndexLabel(4, translate_MA_type(enmG_4_Method)+"("+IntegerToString(intG_4_Val)+"x"+IntegerToString(intG_4_Shift)+")");SetIndexEmptyValue(4,0.0);
      intG_5_IdxStyle = DRAW_LINE;  enmG_5_LineStyle = STYLE_SOLID;  intG_5_Width = 4;   clrG_5 = clrViolet;      intG_5_Val = 47; intG_5_Shift = 0; enmG_5_Method = MODE_EMA;  SetIndexShift(5,intG_5_Shift);SetIndexLabel(5, translate_MA_type(enmG_5_Method)+"("+IntegerToString(intG_5_Val)+"x"+IntegerToString(intG_5_Shift)+")");SetIndexEmptyValue(5,0.0);
      intG_6_IdxStyle = DRAW_LINE;  enmG_6_LineStyle = STYLE_SOLID;  intG_6_Width = 1;   clrG_6 = clrDarkViolet;  intG_6_Val = 76; intG_6_Shift = 0; enmG_6_Method = MODE_EMA;  SetIndexShift(6,intG_6_Shift);SetIndexLabel(6, translate_MA_type(enmG_6_Method)+"("+IntegerToString(intG_6_Val)+"x"+IntegerToString(intG_6_Shift)+")");SetIndexEmptyValue(6,0.0);
      intG_7_IdxStyle = DRAW_LINE;  enmG_7_LineStyle = STYLE_SOLID;  intG_7_Width = 1;   clrG_7 = clrDarkOrchid;  intG_7_Val = 123;intG_7_Shift = 0; enmG_7_Method = MODE_EMA;  SetIndexShift(7,intG_7_Shift);SetIndexLabel(7, translate_MA_type(enmG_7_Method)+"("+IntegerToString(intG_7_Val)+"x"+IntegerToString(intG_7_Shift)+")");SetIndexEmptyValue(7,0.0);
      break;  
   }

   SetIndexBuffer (0,arr_0); SetIndexBuffer (1,arr_1); SetIndexBuffer (2,arr_2);
   SetIndexBuffer (3,arr_3); SetIndexBuffer (4,arr_4); SetIndexBuffer (5,arr_5);
   SetIndexBuffer (6,arr_6); SetIndexBuffer (7,arr_7);

   //wyświetlanie buttona na wykresie
   show_ButtonsOnScreen(strG_Viper,"V",intU_X+intU_Btn_width*0,intU_Y+intU_Btn_hight*1,intU_Btn_width,intU_Btn_hight);
   
   
   //wyświetlanie Vipera na wykresie
   if(blnE_Czy_Widoczny)
   {
      show_Viper_On();
   }
   else
   {
      show_Viper_Off();
      change_Button_State_Off(strG_Viper);//guzik tez
   }
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void show_Viper_On()
{
   if(blnE_Czy_0) SetIndexStyle(0,intG_0_IdxStyle,enmG_0_LineStyle,intG_0_Width,clrG_0); else SetIndexStyle(0,DRAW_NONE);
   if(blnE_Czy_1) SetIndexStyle(1,intG_1_IdxStyle,enmG_1_LineStyle,intG_1_Width,clrG_1); else SetIndexStyle(1,DRAW_NONE);
   if(blnE_Czy_2) SetIndexStyle(2,intG_2_IdxStyle,enmG_2_LineStyle,intG_2_Width,clrG_2); else SetIndexStyle(2,DRAW_NONE);
   if(blnE_Czy_3) SetIndexStyle(3,intG_3_IdxStyle,enmG_3_LineStyle,intG_3_Width,clrG_3); else SetIndexStyle(3,DRAW_NONE);
   if(blnE_Czy_4) SetIndexStyle(4,intG_4_IdxStyle,enmG_4_LineStyle,intG_4_Width,clrG_4); else SetIndexStyle(4,DRAW_NONE);
   if(blnE_Czy_5) SetIndexStyle(5,intG_5_IdxStyle,enmG_5_LineStyle,intG_5_Width,clrG_5); else SetIndexStyle(5,DRAW_NONE);
   if(blnE_Czy_6) SetIndexStyle(6,intG_6_IdxStyle,enmG_6_LineStyle,intG_6_Width,clrG_6); else SetIndexStyle(6,DRAW_NONE);
   if(blnE_Czy_7) SetIndexStyle(7,intG_7_IdxStyle,enmG_7_LineStyle,intG_7_Width,clrG_7); else SetIndexStyle(7,DRAW_NONE); 
}
//+------------------------------------------------------------------+
void show_Viper_Off()
{
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE); 
   SetIndexStyle(2,DRAW_NONE); 
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexStyle(7,DRAW_NONE);
}
//+------------------------------------------------------------------+
//| Custom indicator DeInit function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(ChartID(),strG_Viper);
   ObjectDelete(ChartID(),strG_V_desc);
   ObjectDelete(ChartID(),strG_Shade_V_desc);
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
   if(enmE_Viper_Type == viper_DEMA_20x40)
   {
      int intL_BTC = rates_total-prev_calculated+1;
            
      if       (prev_calculated==0)          //dla pierwszego przelotu
      {
         intL_BTC = Bars;
      } 
      else if  (prev_calculated==rates_total)//przelicza tylko ostatni
      {
         intL_BTC = 0;
      }
      
      for(int i=0;i<intL_BTC;i++)
      {
         arr_0[i] = iCustom(NULL,0,"0 Simons DMA",20,MODE_SMA,i);
         arr_1[i] = iMA(NULL,0,20,0,MODE_SMA, PRICE_MEDIAN,i);
         arr_2[i] = iCustom(NULL,0,"0 Simons DMA",40,MODE_SMA,i);
         arr_3[i] = iCustom(NULL,0,"0 Simons DMA",80,MODE_SMA,i);
      }
   }
    
   else {
   
   //zakresy obliczeń
   int intL_BTC;

   //początek obliczeń
   if       (prev_calculated==0)          //dla pierwszego przelotu
   {
      intL_BTC      = Bars-1;
   }
   else if  (prev_calculated==rates_total)//przelicza tylko ostatni
   {
      intL_BTC   = 0;
   }
   else
   {
      intL_BTC   = rates_total-prev_calculated+1;
   }
   
   //Alert(TimeCurrent(),"Bars To Calculate = ",intL_BTC);
   for(int i=0; i<=intL_BTC; i++)
   {
      arr_0[i] = iMA(NULL,0,intG_0_Val,0,enmG_0_Method, enmG_Price,i);
      arr_1[i] = iMA(NULL,0,intG_1_Val,0,enmG_1_Method, enmG_Price,i);
      arr_2[i] = iMA(NULL,0,intG_2_Val,0,enmG_2_Method, enmG_Price,i);
      arr_3[i] = iMA(NULL,0,intG_3_Val,0,enmG_3_Method, enmG_Price,i);
      arr_4[i] = iMA(NULL,0,intG_4_Val,0,enmG_4_Method, enmG_Price,i);
      arr_5[i] = iMA(NULL,0,intG_5_Val,0,enmG_5_Method, enmG_Price,i);
      arr_6[i] = iMA(NULL,0,intG_6_Val,0,enmG_6_Method, enmG_Price,i);
      arr_7[i] = iMA(NULL,0,intG_7_Val,0,enmG_7_Method, enmG_Price,i);
   }
   
   if(intL_BTC >= Bars-1) intL_BTC = Bars-2;
   
   if(blnE_Czy_ZnakZmianyKierunku)
   {
      if(enmE_Viper_Type == viper_Classic || enmE_Viper_Type == viper_Slower)
      {
         for(int i=0; i<intL_BTC; i++)
         {
            arr_3[i] = 0;
            arr_4[i] = 0;
            
            if       (arr_0[i]>arr_1[i] && arr_0[i+1]< arr_1[i+1])  {arr_3[i] =   arr_0[i];}
            else if  (arr_0[i]<arr_1[i] && arr_0[i+1]> arr_1[i+1])  {arr_4[i] =   arr_0[i];}
         }
      }
      else if(enmE_Viper_Type == viper_7x4)
      {
         for(int i=0; i<intL_BTC; i++)
         {
   
            arr_6[i] = 0;
            arr_7[i] = 0;
            
            if       (arr_0[i]>arr_5[i] && arr_0[i+1]< arr_5[i+1])  {arr_6[i] =   arr_0[i];}
            else if  (arr_0[i]<arr_5[i] && arr_0[i+1]> arr_5[i+1])  {arr_7[i] =   arr_0[i];}
         }
      }
   }
   //koniec duzego ifa
   }
   
   //wyświetalnie opisu na wykresie
   if(prev_calculated!=rates_total)
   if(blnE_Czy_OpisNaEkranie)
   {
      show_DescriptionOnChart();
     //Alert(Period()," ViperGenerujeOpis");
   }
   else ObjectDelete(ChartID(),strG_V_desc);

   //--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
string translate_Viper()
{
   //20180829-20181202
   switch(enmE_Viper_Type)
   {
      case  viper_7x4:        return "Fast_7+";    break;
      case  viper_Classic:    return "Classic";    break;
      case  viper_Slower:     return "Slower";     break;
      case  viper_Rainbow:    return "Rainbow";    break;
      case  viper_DiLines:    return "DiLines";    break;
      case  viper_Alligatgor: return "Alligator";  break;
      default:                return "---";        break;
   }
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if( id == CHARTEVENT_OBJECT_CLICK )
   {
      //ukryvanie geom 22/06/2018
      if(sparam==strG_Viper)
      {       
         
         bool blnL_Button_Viper_State = ObjectGetInteger(lngG_ID,strG_Viper,OBJPROP_STATE);
         if(!blnL_Button_Viper_State)
         {
            show_Viper_On();
            change_Button_State_On(strG_Viper);
         }
         else
         {
            show_Viper_Off();
            change_Button_State_Off(strG_Viper);
         }
      }
   }
}
//+------------------------------------------------------------------+
void show_DescriptionOnChart()
{
   color clrL_Shade  = ChartGetInteger(lngG_ID,CHART_COLOR_BACKGROUND);  
   color clrL_txt    = clrWhite;
   string strL_V  = get_Vipers_Description(enmE_TF_Vipers_TF);
   string strL_VV    = "V("+translate_TF(enmE_TF_Vipers_TF)+"): " + strL_V;

   create_Button  (lngG_ID,strG_Shade_V_desc, 0,72,intU_Y+15, 160, 18, CORNER_LEFT_LOWER,"","Arial",8,clrL_Shade,clrL_Shade,clrL_Shade); //cien 102 przedtem
   create_Label   (lngG_ID,strG_V_desc,       0,72+2,intU_Y-5,         CORNER_LEFT_LOWER,strL_VV,"Arial Black",11,clrL_txt);
   ObjectSetString(lngG_ID, strG_V_desc,OBJPROP_TEXT,strL_VV);

}
//+------------------------------------------------------------------+
string get_Vipers_Description(const ENUM_TIMEFRAMES head_TF = PERIOD_CURRENT)
{
   
   double dblL_Fang  = iMA(NULL,head_TF,11,0, MODE_EMA, PRICE_MEDIAN,1);
   double dblL_Belly = iMA(NULL,head_TF,29,0, MODE_EMA, PRICE_MEDIAN,1);
   double dblL_Tale  = iMA(NULL,head_TF,29,11,MODE_EMA, PRICE_MEDIAN,1);
   string strL_Viper = "-----";

   
   if       (dblL_Fang > dblL_Tale && dblL_Belly > dblL_Tale)
   {
      if       (Close[1]>dblL_Fang)    strL_Viper = "fang bull";
      else if  (Close[1]>dblL_Belly)   strL_Viper = "belly bull";
      else if  (Close[1]>dblL_Tale)    strL_Viper = "tale bull";
      else                             strL_Viper = "weak bull"; 
      //clrL_txt = clrLime;
   }
   
   else if  (dblL_Fang < dblL_Tale && dblL_Belly < dblL_Tale)
   {
      if       (Close[1]<dblL_Fang)    strL_Viper = "fang bear";
      else if  (Close[1]<dblL_Belly)   strL_Viper = "belly bear";
      else if  (Close[1]<dblL_Tale)    strL_Viper = "tale bear";
      else                             strL_Viper = "weak bear"; 
      //clrL_txt = clrRed;
   }
   
   return strL_Viper;
   
}

