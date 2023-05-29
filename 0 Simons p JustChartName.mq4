//+------------------------------------------------------------------+
//|                                     0 Simons p JustChartName.mq4 |
//|                                                     Szymon Marek |
//|                                           https://szymonmarek.pl |
//+------------------------------------------------------------------+
#property copyright "Szymon Marek"
#property link      "https://szymonmarek.pl"
#property version   "1.00"
#property strict
#property indicator_chart_window

//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+

//dodatek z 31/06/2018 nazwa wykresu
string strG_ChartName         = "chart name";
string strG_Shade_Buttons     = "Shade Fibo Buttons";
string strG_Shade_Title       = "Shade Fibo Title";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   string strL_ChartDesc
   
   strL_ChartDesc = Symbol() + " " + translate_TF(enmG_TF);   
   int intL_StringLen = StringLen(strL_ChartDesc)*13+6;
  
   ObjectDelete(strG_Shade_Title);ObjectDelete(strG_ChartName);
   if(!find_Object(strG_Shade_Title))  create_RectLabel (ChartID(),strG_Shade_Title,0,intL_X+16*3+6,28,intL_StringLen,25,clrL_Base,1,CORNER_LEFT_UPPER);
   else {ObjectSetInteger(lngG_ID,strG_Shade_Title,OBJPROP_XSIZE,intL_StringLen);}
   if(!find_Object(strG_ChartName))    create_Label (lngG_ID,strG_ChartName, 0,intL_X+16*3+6,51, CORNER_LEFT_UPPER,strL_ChartDesc,"Century Gothic",16,clrWhite);
   else ObjectSetString(lngG_ID,strG_ChartName,OBJPROP_TEXT,strL_ChartDesc);

   
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

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
   ObjectDelete(ChartID(),strG_Shade_Title);   
   ObjectDelete(ChartID(),strG_ChartName);
}