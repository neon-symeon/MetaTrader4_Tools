//+------------------------------------------------------------------+
//|                                            (c) Szymon Marek 2018 |
//|                                              www.SzymonMarek.com |
//+------------------------------------------------------------------+
#property copyright "(c) Szymon Marek 2018"
#property link      "www.SzymonMarek.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
#property description "Zmienia kolor i grubosc slupkow ignorując O&C price. Umożliwia wyświetlanie wykresu Heiken Ashi. Potrafi pogrubić słupki z wybranych godzin, z godzin sesyjnych na przykład."
//+------------------------------------------------------------------+
#property indicator_buffers 4
double arr_HA_Shadow_Up[], arr_HA_Shadow_Dn[];
double arr_HA_O[], arr_HA_C[];
//+------------------------------------------------------------------+
enum ENUMS_ThickBarType
{
   bar_SimpleThick,
   bar_ColorThin,
   bar_ColorThick,
   bar_ColorCandle,
   bar_HeikenAshi,
   bar_MedianPrice,
   bar_HistoTrend,
   bar_HIstoTrend_Enhanced,
   bar_TrendVsMA,
   bar_No
};
//+------------------------------------------------------------------+
//globalne zewnętrzne
//+------------------------------------------------------------------+
extern string              s0 = "--- Widoczność Oscylatora na Wykresie ---";
extern bool                blnE_Czy_Widoczny    = true;
extern string              s1 = "--- Rodzaj Pogrubionych Barów ---";
extern ENUMS_ThickBarType  enmE_Type            = bar_SimpleThick;
//extern string              s2 = "--- Renko Step ---";
//extern int                 intE_RenkoStep = 10;
string                     s3_0 = "---do Histo Trend Parametr Średniej---";
extern int                 intE_MA_Val = 20;
string                     s3 = "--- czy wyświetlać godziny handlu ---";
bool                       blnE_Czy_TradingHours = false;
int                        intE_Poczatek_Godz   = 8;
int                        intE_Poczatek_Min    = 00;
string                     s3_1 = "-------";
int                        intE_Koniec_Godz     = 17;
int                        intE_Koniec_Min      = 30;
extern string              s10 = "--- Renko Step ---"; //tylko na Enhanced działa
extern ENUM_MA_METHOD      enmE_PriceMode = MODE_SMA;
//+------------------------------------------------------------------+
//globalne zmienne
//+------------------------------------------------------------------+
long     lngG_ID = ChartID();    //chart ID
string   strG_ThickBars = "ThBa"; //nazwa Buttona
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer (0,arr_HA_Shadow_Up);   SetIndexEmptyValue(0,0.0);       
   SetIndexBuffer (1,arr_HA_Shadow_Dn);   SetIndexEmptyValue(1,0.0);
   SetIndexBuffer (2,arr_HA_C);           SetIndexEmptyValue(2,0.0);
   SetIndexBuffer (3,arr_HA_O);           SetIndexEmptyValue(3,0.0);       
   
   //wyświetlanie buttona na wykresie
   show_ButtonsOnScreen(strG_ThickBars,"T",intU_X+intU_Btn_width*3,intU_Y+intU_Btn_hight*1,intU_Btn_width,intU_Btn_hight);

   //wyświetlanie Vipera na wykresie
   if(blnE_Czy_Widoczny)
   {
      show_ThickBars_On();
   }
   else
   {
      show_ThickBars_Off();
      change_Button_State_Off(strG_ThickBars);//guzik tez
   }     
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void show_ThickBars_On()
{
   switch(enmE_Type) 
   { 
   case bar_SimpleThick:
      SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,2,clrWhite);
      SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,2,clrWhite);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
      show_Chart_Colors_On();
      break; 
   case bar_HistoTrend:
   case bar_HIstoTrend_Enhanced:
      SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,3,clrLime);
      SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,3,clrRed);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
      show_Chart_Colors_On();      
      break;       
   case bar_ColorThin:
   case bar_ColorThick:   
      SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,1,clrLime);
      SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,1,clrRed);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
      show_Chart_Colors_Off();
      break;         
   //case bar_ColorThick:   
   //   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,3,clrLime);
   //   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,3,clrRed);
   //   SetIndexStyle(2,DRAW_NONE);
   //   SetIndexStyle(3,DRAW_NONE);
   //   show_Chart_Colors_Off();
   //   break;         
   case bar_ColorCandle:
      SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,2,clrLime);
      SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,2,clrRed);
      SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,5,clrLime);
      SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,5,clrRed);
      show_Chart_Colors_Off();
      break;         
      
   case bar_HeikenAshi:
      SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,1,clrWhite);
      SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,1,clrWhite);
      SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,5,clrLime);
      SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,5,clrRed);
      show_Chart_Colors_Off();
      break;
   case bar_MedianPrice:
      SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,3,clrGold);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
      //show_Chart_Colors_Off();
      break;
      
   case bar_No:
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
      show_Chart_Colors_Off();
   }
}
//+------------------------------------------------------------------+
void show_ThickBars_Off()
{
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_NONE);      
}
//+------------------------------------------------------------------+
void show_Chart_Colors_On()
{
 //przywraca ustawienia wykresu
   ChartSetInteger(lngG_ID,CHART_COLOR_CHART_UP,clrWhite);         //kolory słupków
   ChartSetInteger(lngG_ID,CHART_COLOR_CHART_DOWN,clrWhite);
   ChartSetInteger(lngG_ID,CHART_COLOR_CHART_LINE,clrWhite);
   ChartSetInteger(lngG_ID,CHART_COLOR_CANDLE_BULL,clrWhite);
   ChartSetInteger(lngG_ID,CHART_COLOR_CANDLE_BEAR,clrBlack);
   ChartSetInteger(lngG_ID,CHART_COLOR_BACKGROUND,clrBlack); 
}
//+------------------------------------------------------------------+
void show_Chart_Colors_Off()
{
   //---+ ustawienia wykresu
   lngG_ID = ChartID();
   if(ChartGetInteger(lngG_ID,CHART_COLOR_CHART_UP)!=clrNONE)     ChartSetInteger(lngG_ID,CHART_COLOR_CHART_UP,clrNONE);         //kolory słupków
   if(ChartGetInteger(lngG_ID,CHART_COLOR_CHART_DOWN)!=clrNONE)   ChartSetInteger(lngG_ID,CHART_COLOR_CHART_DOWN,clrNONE);
   if(ChartGetInteger(lngG_ID,CHART_COLOR_CHART_LINE)!=clrNONE)   ChartSetInteger(lngG_ID,CHART_COLOR_CHART_LINE,clrNONE);
   if(ChartGetInteger(lngG_ID,CHART_COLOR_CANDLE_BULL)!=clrNONE)  ChartSetInteger(lngG_ID,CHART_COLOR_CANDLE_BULL,clrNONE);
   if(ChartGetInteger(lngG_ID,CHART_COLOR_CANDLE_BEAR)!=clrNONE)  ChartSetInteger(lngG_ID,CHART_COLOR_CANDLE_BEAR,clrNONE);
   if(ChartGetInteger(lngG_ID,CHART_COLOR_BACKGROUND)!=clrBlack)  ChartSetInteger(lngG_ID,CHART_COLOR_BACKGROUND,clrBlack);   
}
//+------------------------------------------------------------------+
//| Custom indicator DeInit function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(ChartID(),strG_ThickBars);
   show_Chart_Colors_On();
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
   int intL_BTC = rates_total-prev_calculated+1;
   if (prev_calculated==0)                   intL_BTC = Bars-2;
   else if  (prev_calculated==rates_total)   intL_BTC = 0;

   if(enmE_Type == bar_SimpleThick)
   {
      for(int i=0;i<=intL_BTC;i++)
      {
         arr_HA_Shadow_Up[i] = High[i];
         arr_HA_Shadow_Dn[i] = Low[i];
      }
   }
   else if (enmE_Type == bar_TrendVsMA)
   {
     for(int i=0;i<=intL_BTC;i++)
      {

            arr_HA_Shadow_Up[i] = 0;
            arr_HA_Shadow_Dn[i] = 0;
    
         double dblL_BB_M   = iBands(NULL,0,intE_MA_Val,2,0,PRICE_MEDIAN,MODE_MAIN,i);
         
         if(Close[i] > dblL_BB_M)
         {
            arr_HA_Shadow_Up[i] = High[i];
            arr_HA_Shadow_Dn[i] = Low[i];
         }
         else if(Close[i] < dblL_BB_M)
         { 
            arr_HA_Shadow_Up[i] = Low[i];
            arr_HA_Shadow_Dn[i] = High[i];
         }  
      }
   }
   else if(enmE_Type == bar_HistoTrend || enmE_Type == bar_HIstoTrend_Enhanced)
   {
      for(int i=0;i<=intL_BTC;i++)
      {

            arr_HA_Shadow_Up[i] = 0;
            arr_HA_Shadow_Dn[i] = 0;
    
         double dblL_MA     = iMA(NULL,0,3,3,MODE_SMMA, PRICE_MEDIAN,i);
         double dblL_BB_M   = iBands(NULL,0,18,2,0,PRICE_MEDIAN,MODE_MAIN,i);
         
         if(enmE_Type == bar_HIstoTrend_Enhanced)
         {
            dblL_MA     = iMA(NULL,0,2,2,enmE_PriceMode, PRICE_MEDIAN,i);
            dblL_BB_M   = iMA(NULL,0,5,5,enmE_PriceMode, PRICE_MEDIAN,i);
         }
         
         if(Close[i] > dblL_BB_M && Close[i] > dblL_MA)
         //if(dblL_MA>dblL_BB_M && Close[i] >= dblL_MA)
         {
            arr_HA_Shadow_Up[i] = High[i];
            arr_HA_Shadow_Dn[i] = Low[i];
         }
         else if(Close[i] < dblL_BB_M && Close[i] < dblL_MA)
         //else if(dblL_MA<dblL_BB_M && Close[i] <= dblL_MA)
         { 
            arr_HA_Shadow_Up[i] = Low[i];
            arr_HA_Shadow_Dn[i] = High[i];
         }  
      }
   
   }
   else if(enmE_Type == bar_ColorThin || enmE_Type == bar_ColorThick)
   {
      for(int i=0;i<=intL_BTC;i++)
      {
         if(Close[i]>Open[i])
         {
            arr_HA_Shadow_Up[i] = High[i];
            arr_HA_Shadow_Dn[i] = Low[i];
         }
         else
         { 
            arr_HA_Shadow_Up[i] = Low[i];
            arr_HA_Shadow_Dn[i] = High[i];
         }  
      }
   }
   else if(enmE_Type == bar_ColorCandle)
   {
      for(int i=0;i<=intL_BTC;i++)
      {
         if(Close[i]>=Open[i])
         {
            arr_HA_C[i] = Close[i];
            arr_HA_O[i] = Open[i];
            arr_HA_Shadow_Up[i] = High[i];
            arr_HA_Shadow_Dn[i] = Low[i];  
            
         }
         else
         {
            arr_HA_C[i] = Close[i];
            arr_HA_O[i] = Open[i];
            arr_HA_Shadow_Up[i] = Low[i];
            arr_HA_Shadow_Dn[i] = High[i];  
            
         }      
      }
   }
   else if(bar_HeikenAshi)
   {
      for(int i=intL_BTC;i>=0;i--)
      {
         arr_HA_C[i] = (Open[i] + Close[i] + High[i] + Low[i])/4;
      
         if(arr_HA_O[i+1]==0)
            arr_HA_O[i] = (Open[i] + Close[i])/2;
         else
            arr_HA_O[i] = (arr_HA_O[i+1] + arr_HA_C[i+1])/2;
         
         arr_HA_Shadow_Up[i] = High[i];
         arr_HA_Shadow_Dn[i] = Low[i];
      }
   }
   else if(bar_MedianPrice)
   {
      for(int i=0;i<=intL_BTC;i++)
      {
         arr_HA_Shadow_Up[i] = .5*(High[i] - Low[i])+Low[i];
      }
   }
   else if(bar_No)
   {
      for(int i=0;i<=intL_BTC;i++)
      {
            arr_HA_C[i] = 0;
            arr_HA_O[i] = 0;
            arr_HA_Shadow_Up[i] = 0;
            arr_HA_Shadow_Dn[i] = 0;  
      }
   }   
//   for(int i=intL_BTC;i>=0;i--)
//   {
//      if(filter_time(i))
//      {
//         switch(enmE_Type) 
//         {
//         case bar_SimpleThick:
//            arr_HA_Shadow_Up[i] = High[i];
//            arr_HA_Shadow_Dn[i] = Low[i];
//            break;
//         case bar_ColorThin:
//            if(Close[i]>Open[i])
//            {
//               arr_HA_Shadow_Up[i] = High[i];
//               arr_HA_Shadow_Dn[i] = Low[i];
//            }
//            else
//            {
//               arr_HA_Shadow_Up[i] = Low[i];
//               arr_HA_Shadow_Dn[i] = High[i];
//            }
//            break;
//         case bar_ColorCandle:
//            if(Close[i]>Open[i])
//            {
//               arr_HA_C[i] = Close[i];
//               arr_HA_O[i] = Open[i];
//               arr_HA_Shadow_Up[i] = High[i];
//               arr_HA_Shadow_Dn[i] = Low[i];  
//               
//            }
//            else
//            {
//               arr_HA_C[i] = Low[i];
//               arr_HA_O[i] = Open[i];
//               arr_HA_Shadow_Up[i] = Low[i];
//               arr_HA_Shadow_Dn[i] = High[i];  
//               
//            }
//            break;    
//         case bar_HeikenAshi:
//            arr_HA_C[i] = (Open[i] + Close[i] + High[i] + Low[i])/4;
//         
//            if(arr_HA_O[i+1]==0)
//               arr_HA_O[i] = (Open[i] + Close[i])/2;
//            else
//               arr_HA_O[i] = (arr_HA_O[i+1] + arr_HA_C[i+1])/2;
//            
//            arr_HA_Shadow_Up[i] = High[i];
//            arr_HA_Shadow_Dn[i] = Low[i];
//            break;
//         }
//      }
//   } 
   return(rates_total);
}
//+------------------------------------------------------------------+
bool filter_time(int head_i)
{
   
   if(!blnE_Czy_TradingHours) return true;
   if(Period()>PERIOD_H4)     return true;
   
   datetime dttL_TimeBeg = StrToTime(IntegerToString(intE_Poczatek_Godz)+":"+IntegerToString(intE_Poczatek_Min));
   datetime dttL_TimeEnd = StrToTime(IntegerToString(intE_Koniec_Godz)+":"+IntegerToString(intE_Koniec_Min));
   
   int intL_Hour     = TimeHour(Time[head_i]);
   int intL_Minute   = TimeMinute(Time[head_i]);
   
   datetime dttL_i = StrToTime(IntegerToString(intL_Hour)+":"+IntegerToString(intL_Minute));
   
   if(dttL_i>=dttL_TimeBeg && dttL_i<=dttL_TimeEnd) return true;

   return false;
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
      if(sparam==strG_ThickBars)
      {       
         bool blnL_Button_State = ObjectGetInteger(lngG_ID,strG_ThickBars,OBJPROP_STATE);
         if(!blnL_Button_State)
         {
            show_ThickBars_On();
            //show_Chart_Colors_Off();
            change_Button_State_On(strG_ThickBars);
            
         }
         else
         {
            show_ThickBars_Off();
            show_Chart_Colors_On();
            change_Button_State_Off(strG_ThickBars);
         }
      }
   }
}