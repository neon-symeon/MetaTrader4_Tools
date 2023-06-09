//+------------------------------------------------------------------+
//|                                                    Copyright 2019|
//|                                       http://www.SzymonMarek.com |
//+------------------------------------------------------------------+


#property copyright    "(c) 2019 Szymon Marek"
#property link         "www.SzymonMarek.com"
#property strict
#property version      "1.00"
//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+

#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DOT

#property indicator_level1 0

// ustawienia wskaźnika
#property indicator_separate_window

#property indicator_buffers 6

#property indicator_color1 clrLime
#property indicator_width1 3

#property indicator_color2 clrRed
#property indicator_width2 3

//#property indicator_color3 clrGold
//#property indicator_width3 2

#property indicator_color4 clrRed
#property indicator_width4 1

#property indicator_color5 clrLime
#property indicator_width5 1

#property indicator_color6 clrRoyalBlue
#property indicator_width6 3

enum ENUMS_Chart_Type
{
   type_historgram,
   type_lines
};


//+------------------------------------------------------------------+
//+zmienne kontrolowane z zewnątrz
//+------------------------------------------------------------------+
extern bool    blnE_Czy_Linia_1  = true;
//extern int     intE_f_Factor     = 19;
extern int     intE_SMA_Period   = 6;
extern bool    blnE_Czy_TM_Count = true;
//extern double  dblE_Dist         = .6;
//+------------------------------------------------------------------+
//+zmienne globalne
//+------------------------------------------------------------------+
int      intG_Fast_RSI = 19;
int      intG_Slow_RSI = 30;
string   strG_NazwaIndi;
int      intG_WinIdx;
string strG_RSI_Histogram, strG_RSI_Line;
//+------------------------------------------------------------------+
//+definicja tablic
//+------------------------------------------------------------------+
double arr_TrueMom[],  arr_TM_Green[],   arr_TM_Red[], arr_TM_Silver[], arr_TM_Aqua[], arr_TM_Magenta[];
double arr_TM_SigLine[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
{
   //-------------------------------------
   // --- Nazwa wskaźnika
   strG_NazwaIndi="|Simon's True Momentum vs " + IntegerToString(6);  
   IndicatorShortName(strG_NazwaIndi);
   //-------------------------------------
   // --- Dokładność wyświetlania
   IndicatorDigits(2);   
   //-------------------------------------
   //show_AllButtonsOnScreen();
   //-------------------------------------
   //--- bufory dla indeksow rysowanych
   IndicatorBuffers(9);
   SetIndexBuffer (0,arr_TM_Green);    SetIndexStyle(0,DRAW_HISTOGRAM); SetIndexEmptyValue(0,0.0); SetIndexLabel(0,"TM Bull");
   SetIndexBuffer (1,arr_TM_Red);      SetIndexStyle(1,DRAW_HISTOGRAM); SetIndexEmptyValue(1,0.0); SetIndexLabel(1,"TM Bear");
   SetIndexBuffer (2,arr_TM_Silver);   SetIndexStyle(2,DRAW_HISTOGRAM); SetIndexEmptyValue(2,0.0); SetIndexLabel(2,"TM TooFreshTooWatch");
   SetIndexBuffer (3,arr_TM_Aqua);     SetIndexStyle(3,DRAW_HISTOGRAM); SetIndexEmptyValue(3,0.0); SetIndexLabel(3,"TM Aqua Bull");
   SetIndexBuffer (4,arr_TM_Magenta);  SetIndexStyle(4,DRAW_HISTOGRAM); SetIndexEmptyValue(4,0.0); SetIndexLabel(4,"TM Magenta Bear");      
   SetIndexBuffer (5,arr_TM_SigLine);  SetIndexStyle(5,DRAW_NONE);      
   if(blnE_Czy_Linia_1 && intE_SMA_Period >1)
   {
      SetIndexStyle(5,DRAW_LINE);
      SetIndexLabel(5,"TM SMA("+IntegerToString(intE_SMA_Period)+")");
   }
   SetIndexBuffer(8,arr_TrueMom);
   
   if(!blnE_Czy_TM_Count) delete_TM_Count();
   
//--- inicjacja zakończona :)
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator DeInit function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   delete_TM_Count();
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
{
   //---
   int intL_BTC   = rates_total-prev_calculated+1;
   int intL_BTC_l = intL_BTC;
    
   if       (prev_calculated==0)          //dla pierwszego przelotu
   {
      intL_BTC  = rates_total-intG_Slow_RSI;
      intL_BTC_l = intL_BTC-intE_SMA_Period;
      
   } 
   else if  (prev_calculated==rates_total)//przelicza tylko ostatni
   {
      intL_BTC   = 1;
      intL_BTC_l = 1;
   }

   //---
   for(int i=0; i<intL_BTC; i++)
   {
   
      arr_TrueMom[i] = iRSI(NULL,0,intG_Fast_RSI,PRICE_MEDIAN,i) - iRSI(NULL,0,intG_Slow_RSI,PRICE_MEDIAN,i);      
   }
   
   //---
   for(int i=0; i<intL_BTC_l; i++)
      arr_TM_SigLine[i] = iMAOnArray(arr_TrueMom,0,intE_SMA_Period,0,MODE_SMA,i);

   for(int i=0; i<intL_BTC_l; i++)
   {
   
      arr_TM_Green[i] = 0;
      arr_TM_Red[i] = 0;
      arr_TM_Silver[i] = 0;
      arr_TM_Aqua[i] = 0;
      arr_TM_Magenta[i] = 0;
      
      if(i==0)
      {
         arr_TM_Silver[i] = arr_TrueMom[i];
      
         if(arr_TrueMom[0]>0 && arr_TrueMom[0]>arr_TM_SigLine[0])
            SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,2,clrAqua);
         else if(arr_TrueMom[0]<0 && arr_TrueMom[0]<arr_TM_SigLine[0])
            SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,2,clrMagenta);
         else
            SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,1,clrGold);
      }   
      else
      {
         if       (arr_TrueMom[i]>0)
         {
            if(arr_TrueMom[i]>arr_TM_SigLine[i]) arr_TM_Green[i] = arr_TrueMom[i];
            else                                 arr_TM_Magenta[i] = arr_TrueMom[i];
         }
         else
         {
            if(arr_TrueMom[i]< arr_TM_SigLine[i]) arr_TM_Red[i] = arr_TrueMom[i];
            else                                  arr_TM_Aqua[i] = arr_TrueMom[i];
         }
      }
   }
   
   if(prev_calculated!=rates_total && blnE_Czy_TM_Count) TrendCount();
   
   //---
   return(rates_total);
}
//+------------------------------------------------------------------+
void TrendCount()
{
   delete_TM_Count();
   
   intG_WinIdx = WindowFind(strG_NazwaIndi);

   int k=1;
   while(k<1000)//Bars
   {
      if(arr_TrueMom[k]>arr_TM_SigLine[k] && arr_TrueMom[k]>0)
      {
         int intL_b = k;
         int intL_c = 0;
         for(int i=intL_b+1;i<Bars;i++)
         {
            intL_c++;
            if (arr_TrueMom[i]<arr_TM_SigLine[i]|| arr_TrueMom[i]<0)
            {
               if(intL_c>1) create_Text(ChartID(),"TMc"+IntegerToString(intL_b),intG_WinIdx,Time[intL_b],-0.1,IntegerToString(intL_c),"Arial Narrow",10,clrWhite);
               k = i;
               break;
            }
         }
      }
      else if(arr_TrueMom[k]<arr_TM_SigLine[k] && arr_TrueMom[k]<0)
      {
         int intL_b = k;
         int intL_c = 0;
         for(int i=intL_b+1;i<Bars;i++)
         {
            intL_c++;
            if (arr_TrueMom[i]>arr_TM_SigLine[i]|| arr_TrueMom[i]>0)
            {
               if(intL_c>1) create_Text(ChartID(),"TMc"+IntegerToString(intL_b),intG_WinIdx,Time[intL_b], 0.1,IntegerToString(intL_c),"Arial Narrow",10,clrWhite,0,ANCHOR_RIGHT_LOWER);
               k = i;
               break;
            }
         }
      }
      else  k++;
   }
}
//+------------------------------------------------------------------+
void delete_TM_Count()
{
//20190105 kasuje zliczenia
   bool blnL_f = true;
   int intL_p = 0, intL_pp = 0;
   while(blnL_f && !IsStopped()) 
   { 
      blnL_f = false;
      intL_pp++;
      //Alert("przelot ",intL_pp," objektów=",ObjectsTotal());
      for(int i=0;i<ObjectsTotal();i++)
      {
         string strL_TxtName = ObjectName(i);
         //
         if(StringSubstr(strL_TxtName,0,3) == "TMc")
         {
            ObjectDelete(strL_TxtName);
            blnL_f = true;
            intL_p++;            
         }
      }  
   }
   //Alert("Wykasowałem  = ", intL_p," TM Counts w ", intL_pp," przelotach");
}

//+------------------------------------------------------------------+ 
//|                        Buttons                                   | 
//+------------------------------------------------------------------+
bool show_AllButtonsOnScreen()
{
   //guziki
   
   intG_WinIdx = WindowFind(strG_NazwaIndi);

   create_Button(ChartID(),strG_RSI_Histogram,  intG_WinIdx,intU_X,      31,  12,26,CORNER_LEFT_LOWER,"H","Arial",8,clrNavy,clrPowderBlue);
   create_Button(ChartID(),strG_RSI_Line,       intG_WinIdx,intU_X+12*3, 31,  12,26,CORNER_LEFT_LOWER,"L","Arial",8,clrNavy,clrPowderBlue);
//   
//   create_Button(ChartID(),strG_RSI_ell_1,intG_WinIdx,intU_X+12*1, 31,  12,13,CORNER_LEFT_LOWER,"1","Arial",8);
//   create_Button(ChartID(),strG_RSI_ell_2,intG_WinIdx,intU_X+12*2, 31,  12,13,CORNER_LEFT_LOWER,"2","Arial",8);
//   create_Button(ChartID(),strG_RSI_ell_3,intG_WinIdx,intU_X+12*1, 18,  12,13,CORNER_LEFT_LOWER,"3","Arial",8);
//   create_Button(ChartID(),strG_RSI_ell_4,intG_WinIdx,intU_X+12*2, 18,  12,13,CORNER_LEFT_LOWER,"4","Arial",8);

   return true;
}
//+------------------------------------------------------------------+
bool del_AllButtons()
{
   ObjectDelete(strG_RSI_Histogram);
   ObjectDelete(strG_RSI_Line);
   return true;
}