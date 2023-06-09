//+------------------------------------------------------------------+
//|                                                SIMON fractals.mq4|
//+------------------------------------------------------------------+

//| 2018.11.25 uniwersalizacja
//| 2018.08.22 zmiana w kierunku upraszczania
//| 2015.04.01 potwierdzone i sprawdzone. licencja wydłużona do końca 2015 roku 
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
#property copyright "(c)Szymon Marek 2014-2018"
#property link      "www.SzymonMarek.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property description "Simon's Fractals"
#property description " "
#property description "Ooparte na fraktalach Billa Williamsa, zmieniony nieco wygląd i przedłużone linie dla łatwiejszej identyfikacji kluczowych poziomów. Możliwość rysowania linii baj/sell wokół wstęgi"

//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
#property indicator_buffers 4
//+------------------------------------------------------------------+
double arr_FU[];
double arr_FL[];
double arr_FU_[];
double arr_FL_[];
//+------------------------------------------------------------------+
//globalne zewnętrzne
//+------------------------------------------------------------------+
extern string  s0                = "--- Widoczność Oscylatora na Wykresie ---";
extern bool    blnE_Czy_Widoczny = true; //czy widoczny
extern bool    blnE_Czy_Buy_Sell_Fractal = false;
extern int     intE_BB_val               = 55;
//+------------------------------------------------------------------+
//globalne zmienne
//+------------------------------------------------------------------+
string   strG_NazwaIndi;
long     lngG_ID           = ChartID();   //chart ID
int      intG_Bars         = Bars;
int      intE_Dots_Reach   = 34;
string   strG_Fractal      = "sFractals";
string   strG_Buy_Line = "Fractal Buy Line", strG_Sell_Line = "Fractal Sell Line";
//|------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorDigits(Digits());
   
   //--- ustawienia buforow dla wskaznika
   SetIndexBuffer(0,arr_FU);  SetIndexEmptyValue(0,0.0); SetIndexArrow(0,158); 
   SetIndexBuffer(1,arr_FL);  SetIndexEmptyValue(1,0.0); SetIndexArrow(1,158); 

   SetIndexBuffer(2,arr_FU_); SetIndexArrow(2,158);   SetIndexEmptyValue(2,0.0); SetIndexLabel(2,"Fractal Up");
   SetIndexBuffer(3,arr_FL_); SetIndexArrow(3,158);   SetIndexEmptyValue(3,0.0); SetIndexLabel(3,"Fractal Dn");

   //---
   strG_NazwaIndi=StringConcatenate("sFractals");
   IndicatorShortName(strG_NazwaIndi);    

   //wyświetlanie buttona na wykresie
   show_ButtonsOnScreen(strG_Fractal,"F",intU_X+intU_Btn_width*1,intU_Y+intU_Btn_hight*1,intU_Btn_width,intU_Btn_hight);
   //wyświetlanie oscy na wykresie
   if(blnE_Czy_Widoczny)
   {
      show_Fractal_On();
   }
   else
   {
      show_Fractal_Off();
      delete_Fractal_Signal_Lines();
      change_Button_State_Off(strG_Fractal);//guzik tez
   }

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void show_Fractal_On()
{
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,3,clrLime);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,3,clrRed);
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,1,clrLime);
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,1,clrRed);
}
//+------------------------------------------------------------------+
void show_Fractal_Off()
{
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE); 
   SetIndexStyle(2,DRAW_NONE); 
   SetIndexStyle(3,DRAW_NONE);
}
//+------------------------------------------------------------------+
//| Custom indicator DeInit function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(ChartID(),strG_Fractal);
   delete_Fractal_Signal_Lines();
   Comment(" ");
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
   int intL_BTC = 0;
      
   if       (prev_calculated==0 || intG_Bars!=Bars)
   {
      intL_BTC  = Bars-3;
      intG_Bars = Bars;
   }
   else if  (prev_calculated==rates_total)   //nic nie przelicza
   {
      return(rates_total);
   }
   else
   {
      intG_Bars = Bars;
      for(int i=1;i<144;i++)                 //cofa do ost znalezionego fraktala
      {
         if(i>=Bars-3)
         {
            intL_BTC = i;
            break;
         }
         else if(arr_FL[i]>0 || arr_FU[i]>0)
         {
            intL_BTC = i+1;
            if(intL_BTC > Bars-3) intL_BTC = Bars-3;
            break;         
         }
      }
      if(intL_BTC == 0)
      {
         intL_BTC = rates_total - prev_calculated + 3;
         Alert(Symbol()," ",Period()," Fractals FORCED check ",intL_BTC," bars back");
      }
   }
   
   // 
   int intL_max_calc;  
   for(int i=3;i<intL_BTC;i++)
   {      
      intL_max_calc = i;
      
      if(High[i]>=High[i+1] && High[i]>=High[i+2])
      if(High[i]>=High[i-1] && High[i]>=High[i-2])
      {
         arr_FU[i] = High[i];
         
         for(int j=i-1;j>=i-intE_Dots_Reach;j--)
         {
            if(j<0) break;
            if(arr_FU[j]>0) break; // nie nachodzi na kolejny
            arr_FU_[j] = arr_FU[i];
         }
      }
      
      if(Low[i]<=Low[i+1] && Low[i]<=Low[i+2])
      if(Low[i]<=Low[i-1] && Low[i]<=Low[i-2])
      {
         arr_FL[i] = Low[i];
         for(int j=i-1;j>=i-intE_Dots_Reach;j--)
         {
            if(j<0) break;
            if(arr_FL[j]>0) break; // nie nachodzi na kolejny            
            arr_FL_[j] = arr_FL[i];
         }
      }
   }
   //rysowanie linii baj sell fraktal
   if(rates_total!=prev_calculated) draw_Fractal_Signal_Lines();
   
   return(rates_total);
}
//+------------------------------------------------------------------+
void draw_Fractal_Signal_Lines()
{
   //rysowanie linii baj sell fraktali
   if(blnE_Czy_Buy_Sell_Fractal && !ObjectGetInteger(ChartID(),strG_Fractal,OBJPROP_STATE))
   {
      delete_Fractal_Signal_Lines();

      for(int i=3;i<Bars;i++)
      {
         double dblL_BB_M_H = iBands(NULL,0,intE_BB_val,2,0,PRICE_HIGH,MODE_MAIN,1);
         double dblL_BB_M_H_i = iBands(NULL,0,intE_BB_val,2,0,PRICE_HIGH,MODE_MAIN,i);
         
         if(arr_FU[i]>dblL_BB_M_H && arr_FU[i]>dblL_BB_M_H_i)
         {
            create_Trend(0,strG_Buy_Line,Time[i],High[i],Time[0],High[i],clrLime,STYLE_SOLID,2,false,false);
            break;
         }
      }
      for(int i=3;i<Bars;i++)
      {
         double dblL_BB_M_L   = iBands(NULL,0,intE_BB_val,2,0,PRICE_LOW, MODE_MAIN,1);
         double dblL_BB_M_L_i = iBands(NULL,0,intE_BB_val,2,0,PRICE_LOW, MODE_MAIN,i);
         if(arr_FL[i]>0 && arr_FL[i]<dblL_BB_M_L && arr_FL[i]<dblL_BB_M_L_i)
         {
            create_Trend(0,strG_Sell_Line,Time[i],Low[i],Time[0],Low[i],clrRed,STYLE_SOLID,2,false,false);
            break;
         }
      }
   }
}
//+------------------------------------------------------------------+
void delete_Fractal_Signal_Lines()
{
   ObjectDelete(ChartID(),strG_Buy_Line);
   ObjectDelete(ChartID(),strG_Sell_Line);
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
      if(sparam==strG_Fractal)
      {
         
         bool blnL_Button_Fractal_State = ObjectGetInteger(lngG_ID,strG_Fractal,OBJPROP_STATE);
         if(!blnL_Button_Fractal_State)
         {
            show_Fractal_On();
            change_Button_State_On(strG_Fractal);
            draw_Fractal_Signal_Lines();
         }
         else
         {
            show_Fractal_Off();
            change_Button_State_Off(strG_Fractal);
            delete_Fractal_Signal_Lines();
         }
      }
   }
}
//+------------------------------------------------------------------+