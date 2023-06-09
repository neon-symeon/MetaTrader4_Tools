//+------------------------------------------------------------------+
//|                                                    SIMON DO.mq4  |
//|                                                      neon_symeon |
//|                                        http://www.SzymonMarek.pl |
//+------------------------------------------------------------------+

//20180426  dodałem opcje na X, czyli 18,11,4,3 i to jest cool

//20150913 g. 7:13
//    zmieniłem formuły na automatyczne średnie a nie liczone tutaj oraz dodałem zakres rysowania oscylatora zeby miec
//    sam początek dobrze zrobiony, zmiana sposobu liczenia co daje de facto inne, szybsze o dokładniejsze zygnaly
// 20150309 g. 7:02
// dodałem    IndicatorDigits(2), co spowodowało, ze chodzi teraz IDENTYcznie jak w oryginale :)

#property copyright "(c) Szymon Marek 2014-2018"
#property link      "www.SzymonMarek.com"
#property version   "1.23"
#property description "Based upon The StochRSI developed by Tushar Chande and Stanley Kroll"
#property description "and detailed in the book The New Technical Trader published in 1994"
#property description "---"
#property description "metoda obliczania ceny:"
#property description "T - Price Typical, C - Price Close"
#property description "---"
#property description "ustawienia DO:"
#property description "X -  oryginalne"
#property description "0-4 - autorska modyfikacja"
#property description "RM1-RM3 - najbardziej popularene ustawienia Roberta Minera"

#property strict
#property indicator_separate_window
//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 4
#property indicator_color1 clrAqua    //   fast line
#property indicator_color2 clrFuchsia //   slow line

#property indicator_color3 clrLime  //dots
#property indicator_width3 1
#property indicator_color4 clrRed
#property indicator_width4 1

#property indicator_level1 20
#property indicator_level2 50
#property indicator_level3 80
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DOT

extern   ENUMS_DO_SET      enmE_DO_Set =  set_1;

ENUM_APPLIED_PRICE   enmG_PriceType;
ENUM_MA_METHOD       MA_Type        = MODE_SMA;

int RSI_Length, STOCH_Legth, MA1_Length, MA2_Length;

double arr_FastLine[];
double arr_SlowLine[];
double arr_BullArrow[];
double arr_BearArrow[];

double ArrRSI[];
double ArrSTOCH[];
double ArrSOCHRSI[];

string strG_NazwaIndi;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   enmG_PriceType = PRICE_TYPICAL;
   string strL_Set_Val = translate_DO_settings(enmE_DO_Set);
   switch(enmE_DO_Set)
   {
      case  set_X: RSI_Length=18; STOCH_Legth=14;   MA1_Length=4;  MA2_Length=3;       enmG_PriceType = PRICE_CLOSE; strL_Set_Val = "(18,14,4,3).C";     break;
      case  set_0: RSI_Length=7;  STOCH_Legth=4;    MA1_Length=3;  MA2_Length=2;                                     strL_Set_Val = "(7,4,3,2).T";       break;
      case  set_1: RSI_Length=11; STOCH_Legth=7;    MA1_Length=4;  MA2_Length=3;                                     strL_Set_Val = "(11,7,4,3).T";      break;
      case  set_2: RSI_Length=18; STOCH_Legth=11;   MA1_Length=7;  MA2_Length=4;                                     strL_Set_Val = "(18,11,7,4).T";     break;
      case  set_3: RSI_Length=29; STOCH_Legth=18;   MA1_Length=11; MA2_Length=7;                                     strL_Set_Val = "(29,18,11,7).T";    break;
      case  set_4: RSI_Length=47; STOCH_Legth=29;   MA1_Length=18; MA2_Length=11;                                    strL_Set_Val = "(47,29,18,11).T";   break;
      case  set_RM_1: RSI_Length=8;    STOCH_Legth=5;    MA1_Length=3;  MA2_Length=3;  enmG_PriceType = PRICE_CLOSE; strL_Set_Val = "(8,5,3,3).C";       break;
      case  set_RM_2: RSI_Length=13;   STOCH_Legth=8;    MA1_Length=5;  MA2_Length=5;  enmG_PriceType = PRICE_CLOSE; strL_Set_Val = "(13,8,5,5).C";      break;
      case  set_RM_3: RSI_Length=21;   STOCH_Legth=13;   MA1_Length=8;  MA2_Length=8;  enmG_PriceType = PRICE_CLOSE; strL_Set_Val = "(21,13,8,5).C";     break;
      default    : RSI_Length=11; STOCH_Legth=7;    MA1_Length=4;  MA2_Length=3; strL_Set_Val = "1";  break;
   }
      
   strG_NazwaIndi=StringConcatenate("Simon's Dynamic Oscillator |",strL_Set_Val,"|");
   IndicatorShortName(strG_NazwaIndi);
//--- trzy dodatkowy bufor jest potrzebny do wykorzystania
   IndicatorBuffers(7);

//--- mapowanie
   SetIndexBuffer(0,arr_FastLine); SetIndexDrawBegin(0,RSI_Length+MA2_Length);
   SetIndexBuffer(1,arr_SlowLine); SetIndexDrawBegin(1,RSI_Length+MA1_Length+1);
   
   SetIndexBuffer(2,arr_BullArrow);
   SetIndexBuffer(3,arr_BearArrow);   
   
   SetIndexBuffer(4,ArrRSI);
   SetIndexBuffer(5,ArrSTOCH);
   SetIndexBuffer(6,ArrSOCHRSI);
   
   SetIndexStyle(0,DRAW_LINE);   SetIndexLabel(0,"Fast Line");
   SetIndexStyle(1,DRAW_LINE);   SetIndexLabel(1,"Slow Line"); 
   SetIndexStyle(2,DRAW_ARROW);  SetIndexLabel(2,"Bull Arrow"); SetIndexArrow(2,159);         SetIndexEmptyValue(2,0.0);
   SetIndexStyle(3,DRAW_ARROW);  SetIndexLabel(3,"Bear Arrow"); SetIndexArrow(3,159);         SetIndexEmptyValue(3,0.0);

   IndicatorDigits(1);
   
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
   int intL_BTC1 = rates_total-prev_calculated+1;
   int intL_BTC2 = intL_BTC1;
   int intL_BTC3 = intL_BTC1;
   int intL_BTC4 = intL_BTC1;
   int intL_BTC5 = intL_BTC1;
         
   if       (prev_calculated==0)          //dla pierwszego przelotu
   {
      intL_BTC1 = Bars;
      intL_BTC2 = intL_BTC1-STOCH_Legth;
      intL_BTC3 = intL_BTC2;
      intL_BTC4 = intL_BTC3-1;
      intL_BTC5 = intL_BTC4; 
   } 
   else if  (prev_calculated==rates_total)//przelicza tylko ostatni
   {
      intL_BTC1 = 0;
      intL_BTC2 = 0;
      intL_BTC3 = 0;
      intL_BTC4 = 0;
      intL_BTC5 = 0;
   }
   //obliczam rsi
   for (int i=0;i<intL_BTC1;i++)
      ArrRSI[i]=iRSI(NULL,0,RSI_Length,enmG_PriceType,i);

   //stochastyczny rsi wynosi 
   for (int i=0;i<intL_BTC2;i++)
      if(HighestRSI(i)-LowestRSI(i)!=0)
         ArrSOCHRSI[i]=100*((ArrRSI[i]-LowestRSI(i))/(HighestRSI(i)-LowestRSI(i)));

   for (int i=0;i<intL_BTC3;i++)     
     arr_FastLine[i]=iMAOnArray(ArrSOCHRSI,0,MA1_Length,0,MA_Type,i);  

   for (int i=0;i<intL_BTC4;i++)
      arr_SlowLine[i]=iMAOnArray(arr_FastLine,0,MA2_Length,0,MA_Type,i);

   for (int i=1;i<intL_BTC5;i++)
   {
      arr_BullArrow[i]=0;
      arr_BearArrow[i]=0;
            
      if(arr_FastLine[i]>arr_SlowLine[i])
      if(arr_FastLine[i+1]<arr_SlowLine[i+1])
      {
         arr_BullArrow[i]=arr_SlowLine[i];
      }
      if(arr_FastLine[i]<arr_SlowLine[i])
      if(arr_FastLine[i+1]>arr_SlowLine[i+1])
      {
         arr_BearArrow[i]=arr_SlowLine[i];
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
double LowestRSI(int Shift)
{
///2014 11 19 23:20
   double dblLowest=ArrRSI[Shift];
   
   for (int i=Shift;i<Shift+STOCH_Legth;i++)
   {
   if(ArrRSI[i]<dblLowest)
      dblLowest=ArrRSI[i];
   }
   
   return dblLowest;
}
//+------------------------------------------------------------------+
double HighestRSI(int Shift)
{
///2014 11 19 23:21
   double dblHighest=0;
   
   for (int i=Shift;i<Shift+STOCH_Legth;i++)
   if(ArrRSI[i]>dblHighest)
      dblHighest=ArrRSI[i];
   
   return dblHighest;
}