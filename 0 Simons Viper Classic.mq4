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
#property description "Simon's Viper. Co-invention with Bill Williams'es Alligator and similar to Moving Averages by Joe Di Napoli."
#property description " "
#property description "What does Viper do? Viper climbs a bamboo tree or falls from it rapidly."

#property indicator_buffers 3
double arr_Fang[], arr_Belly[], arr_Tale[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer (0,arr_Fang);  SetIndexStyle(0,DRAW_LINE,EMPTY,0,clrLime);
   SetIndexBuffer (1,arr_Belly); SetIndexStyle(1,DRAW_LINE,EMPTY,1,clrRed);
   SetIndexBuffer (2,arr_Tale);  SetIndexStyle(2,DRAW_LINE,EMPTY,2,clrRoyalBlue);   SetIndexShift(2,11);
   
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
   
   //zakresy obliczeń
   int                                       intL_BTC = rates_total-prev_calculated+1;
   if       (prev_calculated==0)             intL_BTC = Bars-1;
   else if  (prev_calculated==rates_total)   intL_BTC = 0;

   for(int i=0; i<=intL_BTC; i++)
   {
      arr_Fang[i] = iMA(NULL,0,11,0,MODE_EMA, PRICE_MEDIAN,i);
      arr_Belly[i]= iMA(NULL,0,29,0,MODE_EMA, PRICE_MEDIAN,i);
      arr_Tale[i] = iMA(NULL,0,29,0,MODE_EMA, PRICE_MEDIAN,i);
   }

   //--- return value of prev_calculated for next call
   return(rates_total);
}
