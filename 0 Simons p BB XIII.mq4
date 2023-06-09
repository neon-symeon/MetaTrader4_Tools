//20181227  bb10 jako esencja bb. echa tego na mniejszych skalach generują wyższe bb
//+------------------------------------------------------------------+
#property copyright "(c)Szymon Marek 2023"
#property link      "www.SzymonMarek.com"
#property version   "1.01"
#property strict
#property indicator_chart_window
#property description "Simon's XIII Bands"

//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+

#property indicator_buffers 8

//+------------------------------------------------------------------+
double arr_bb_l2[], arr_bb_l1[], arr_bb_m[], arr_bb_u1[], arr_bb_u2[], arr_TREND_LINE[], arr_bb_52L[], arr_bb_52H[];
//+------------------------------------------------------------------+
//+ zmienne globalne
//+------------------------------------------------------------------+
long              lngG_ID        = ChartID();   //chart ID
string            strG_Symbol    = Symbol();
string            strG_NazwaIndi;
string            strG_BB_XIII  = "BB_13"; //nazwa Buttona
ENUM_TIMEFRAMES   enmG_TF_1st = Period();
string            strG_TF_1st = translate_TF(enmG_TF_1st);
ENUM_TIMEFRAMES   enmG_TF_2nd;
string            strG_TF_2nd="";


//+------------------------------------------------------------------+
//globalne zewnętrzne
//+------------------------------------------------------------------+
extern string        s1 = "--- Widoczność Oscylatora na Wykresie ---";
extern bool                   blnE_Czy_Widoczny = true;
extern string        s2 = " Ustawienia Linii";
extern color                  clrE_linie     = clrGray;     //Kolor Linii
extern string        s3 = "--- *** Parametry Wstęgi Małej *** ---";
extern int                    intE_BB_val    = 13;
extern string        s4 = "--- *** Parametry Wstęgi Dużej *** ---";
extern int                    intE_BB_2_val    = 52;
extern string        s5 = "--- Fixed Time Frame ---";
extern ENUM_TIMEFRAMES        enmE_TF = PERIOD_CURRENT;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //timeframe
   if    (enmE_TF == PERIOD_CURRENT)   enmG_TF_2nd = Period();
   else                                enmG_TF_2nd = enmE_TF; 
   
   strG_TF_2nd = translate_TF(enmG_TF_2nd);

   //--- nazwa
   strG_NazwaIndi = "Simons BB XIII";
   if(enmE_TF!=PERIOD_CURRENT)   strG_NazwaIndi = strG_NazwaIndi + " |" + strG_TF_2nd + "(" + IntegerToString(intE_BB_val)+")";
   IndicatorShortName(strG_NazwaIndi);   
   
   //--- buforowanie
   SetIndexBuffer(0,arr_bb_l2);    SetIndexEmptyValue(0,0.0); SetIndexLabel(0,"L2_"+IntegerToString(intE_BB_val));
   SetIndexBuffer(1,arr_bb_l1);    SetIndexEmptyValue(1,0.0); SetIndexLabel(1,"L1_"+IntegerToString(intE_BB_val));
   SetIndexBuffer(2,arr_bb_m);     SetIndexEmptyValue(2,0.0); SetIndexLabel(2,"M_"+IntegerToString(intE_BB_val));
   SetIndexBuffer(3,arr_bb_u1);    SetIndexEmptyValue(3,0.0); SetIndexLabel(3,"U1_"+IntegerToString(intE_BB_val));
   SetIndexBuffer(4,arr_bb_u2);    SetIndexEmptyValue(4,0.0); SetIndexLabel(4,"U2_"+IntegerToString(intE_BB_val));

   SetIndexBuffer(5,arr_TREND_LINE); SetIndexEmptyValue(5,0.0); SetIndexLabel(5,"Trend Line"+IntegerToString(intE_BB_2_val));

   SetIndexBuffer(6, arr_bb_52L); SetIndexEmptyValue(6,0.0); SetIndexLabel(6,"BB_L_"+IntegerToString(intE_BB_2_val));
   SetIndexBuffer(7, arr_bb_52H); SetIndexEmptyValue(7,0.0); SetIndexLabel(7,"BB_H_"+IntegerToString(intE_BB_2_val));

   
   //-- wyświetlanie buttona na wykresie
   string strL_Button_Txt = "13";
   if(intE_BB_val!=13 || enmE_TF!=PERIOD_CURRENT) strL_Button_Txt = "**"; 
   show_ButtonsOnScreen(strG_BB_XIII,strL_Button_Txt,intU_X+intU_Btn_width*1,intU_Y+intU_Btn_hight*2,intU_Btn_width,intU_Btn_hight);
   
   //wyświetlanie oscy na wykresie
   if(blnE_Czy_Widoczny)
   {
      show_BB_On();
   }
   else
   {
      show_BB_Off();
      change_Button_State_Off(strG_BB_XIII);//guzik tez
   }
   //---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void show_BB_On()
{

   SetIndexStyle(0,DRAW_LINE,STYLE_DOT,1,clrE_linie);
   SetIndexStyle(1,DRAW_LINE,STYLE_DASHDOT,1,clrE_linie);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,clrE_linie);
   SetIndexStyle(3,DRAW_LINE,STYLE_DASHDOT,1,clrE_linie);
   SetIndexStyle(4,DRAW_LINE,STYLE_DOT,1,clrE_linie);
   
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,3,clrRoyalBlue);

   SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,2,clrGray);
   SetIndexStyle(7,DRAW_LINE,STYLE_SOLID,2,clrGray);
   
   
}
//+------------------------------------------------------------------+
void show_BB_Off()
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
   ObjectDelete(ChartID(),strG_BB_XIII);
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
   //
   int intL_BTC = rates_total-prev_calculated+1;
   
   if       (prev_calculated==0)             intL_BTC=Bars-1; 
   else if  (prev_calculated==rates_total)   intL_BTC=0;
   else
   {
      //
      if(enmE_TF!=PERIOD_CURRENT)
      if(iBarShift(NULL,enmG_TF_2nd,Time[0]) != iBarShift(NULL,enmG_TF_2nd,Time[1]))
      {
         for(int i=2;i<Bars-1;i++)
         if(iBarShift(NULL,enmG_TF_2nd,Time[i])!=iBarShift(NULL,enmG_TF_2nd,Time[i+1]))
         {
            intL_BTC  = i+1;
            ENUM_TIMEFRAMES enmL_TF = Period();
            break;
         }
      } 
   }
   //
   if(enmE_TF==PERIOD_CURRENT)
   {
      for(int i=0;i<=intL_BTC;i++)
      {
         arr_bb_l2[i]  = iBands(NULL,0,intE_BB_val,2,0,PRICE_MEDIAN,MODE_LOWER,i);
         arr_bb_l1[i]  = iBands(NULL,0,intE_BB_val,1,0,PRICE_MEDIAN,MODE_LOWER,i);
         arr_bb_m[i]   = iBands(NULL,0,intE_BB_val,1,0,PRICE_MEDIAN,MODE_MAIN,i);
         arr_bb_u1[i]  = iBands(NULL,0,intE_BB_val,1,0,PRICE_MEDIAN,MODE_UPPER,i);
         arr_bb_u2[i]  = iBands(NULL,0,intE_BB_val,2,0,PRICE_MEDIAN,MODE_UPPER,i);
         
         arr_TREND_LINE[i] = iMA(NULL,0,intE_BB_2_val,00,MODE_SMA,PRICE_MEDIAN,i);
         
         arr_bb_52L[i]  = iBands(NULL,0,intE_BB_2_val,2,0,PRICE_MEDIAN,MODE_LOWER,i);
         arr_bb_52H[i]  = iBands(NULL,0,intE_BB_2_val,2,0,PRICE_MEDIAN,MODE_UPPER,i);                  
      }
   }
   else
   {
      for(int i=0;i<=intL_BTC;i++)
      {
         int intL_HTF  = iBarShift(NULL,enmG_TF_2nd,Time[i]);
         arr_bb_l2[i]  = iBands(NULL,enmG_TF_2nd,intE_BB_val,2,0,PRICE_MEDIAN,MODE_LOWER,intL_HTF);         
         arr_bb_l1[i]  = iBands(NULL,enmG_TF_2nd,intE_BB_val,1,0,PRICE_MEDIAN,MODE_LOWER,intL_HTF);
         arr_bb_m[i]   = iBands(NULL,enmG_TF_2nd,intE_BB_val,1,0,PRICE_MEDIAN,MODE_MAIN,intL_HTF);
         arr_bb_u1[i]  = iBands(NULL,enmG_TF_2nd,intE_BB_val,1,0,PRICE_MEDIAN,MODE_UPPER,intL_HTF);
         arr_bb_u2[i]  = iBands(NULL,enmG_TF_2nd,intE_BB_val,2,0,PRICE_MEDIAN,MODE_UPPER,intL_HTF);

         arr_TREND_LINE[i] = iMA(NULL,enmG_TF_2nd,intE_BB_2_val,00,MODE_SMA,PRICE_MEDIAN,intL_HTF);

         arr_bb_52L[i]  = iBands(NULL,enmG_TF_2nd,intE_BB_2_val,2,0,PRICE_MEDIAN,MODE_LOWER,intL_HTF);
         arr_bb_52H[i]  = iBands(NULL,enmG_TF_2nd,intE_BB_2_val,2,0,PRICE_MEDIAN,MODE_UPPER,intL_HTF);           
      }
   }
   //--- return value of prev_calculated for next call
   return(rates_total);
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
      if(sparam==strG_BB_XIII)
      {         
         bool blnL_Button_BB_State = ObjectGetInteger(lngG_ID,strG_BB_XIII,OBJPROP_STATE);
         if(!blnL_Button_BB_State)
         {
            show_BB_On();
            change_Button_State_On(strG_BB_XIII);
         }
         else
         {
            show_BB_Off();
            change_Button_State_Off(strG_BB_XIII);
         }
      }
   }
}