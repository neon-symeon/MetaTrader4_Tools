//20181227  bb10 jako esencja bb. echa tego na mniejszych skalach generują wyższe bb
//+------------------------------------------------------------------+
#property copyright "(c)Szymon Marek 2018"
#property link      "www.SzymonMarek.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property description "Simon's X Bands"
#property description " "
#property description "X Bands określa standardowe ramy kierunku ruchu ceny z użyciem średniej SMA10. Możliwe moddyfikacje docelowych ustawień."
#property description " "
#property description "A Bollinger Band® is a set of lines plotted two standard deviations (positively and negatively) away from a simple moving average of the security's price. A Bollinger Band®, developed by famous technical trader John Bollinger."

//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
enum ENUM_Lines_Thickness
{
   thick_1=1,
   thick_2,
   thick_3,
   thick_4,
   thick_5
};
#property indicator_buffers 3
//+------------------------------------------------------------------+
double arr_bb_u[], arr_bb_m[],arr_bb_l[];
//+------------------------------------------------------------------+
//+ zmienne globalne
//+------------------------------------------------------------------+
long              lngG_ID        = ChartID();   //chart ID
string            strG_Symbol    = Symbol();
string            strG_NazwaIndi;
string            strG_BB        = "BB 10"; //nazwa Buttona
ENUM_TIMEFRAMES   enmG_TF_1st = Period();
string            strG_TF_1st = translate_TF(enmG_TF_1st);
ENUM_TIMEFRAMES   enmG_TF_2nd;
string            strG_TF_2nd="";
bool     blnG_CzyAlertUp = true;
bool     blnG_CzyAlertMd = true;
bool     blnG_CzyAlertDn = true;
//+------------------------------------------------------------------+
//globalne zewnętrzne
//+------------------------------------------------------------------+
extern string        s1 = "--- Widoczność Oscylatora na Wykresie ---";
extern bool                   blnE_Czy_Widoczny = true;
extern string        s1_1 = "--- Widoczność poszczególnych grup Linii---";
extern bool                   blnE_Czy_Gora     = true;
extern bool                   blnE_Czy_Srodek   = true;
extern bool                   blnE_Czy_Dol      = true;
extern string        s2 = " Ustawienia Linii";
extern ENUM_LINE_STYLE        enmE_LiStyle   = STYLE_SOLID; //Styl Linii
extern color                  clrE_linie     = clrAqua;     //Kolor Linii
extern ENUM_Lines_Thickness   enmE_LiTh      = thick_1;     //Grubość Linii
extern string        s3 = "--- *** Parametry Wstęgi *** ---";
extern int                    intE_BB_val    = 10;
extern double                 dblE_BB_dev    = 2.0;
extern string        s4 = "--- Fixed Time Frame ---";
extern ENUM_TIMEFRAMES        enmE_TF = PERIOD_CURRENT;
extern string        s00="------------------------------";
extern bool          blnE_Czy_Alerts  = false; //Czy Alerty

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
   strG_NazwaIndi = "Simons BB X";
   if(enmE_TF!=PERIOD_CURRENT)   strG_NazwaIndi = strG_NazwaIndi + " |" + strG_TF_2nd + "|";
   if(blnE_Czy_Alerts)           strG_NazwaIndi = strG_NazwaIndi + " ALERTS";
   IndicatorShortName(strG_NazwaIndi);   
   //--- buforowanie
   SetIndexBuffer(0,arr_bb_u);    SetIndexEmptyValue(0,0.0); SetIndexLabel(0,"U|"+IntegerToString(intE_BB_val));
   SetIndexBuffer(1,arr_bb_m);    SetIndexEmptyValue(1,0.0); SetIndexLabel(1,"M|"+IntegerToString(intE_BB_val));
   SetIndexBuffer(2,arr_bb_l);    SetIndexEmptyValue(2,0.0); SetIndexLabel(2,"L|"+IntegerToString(intE_BB_val));
   //-- wyświetlanie buttona na wykresie
   string strL_Button_Txt = "X";
   if(intE_BB_val!=10 || enmE_TF!=PERIOD_CURRENT) strL_Button_Txt = "X*"; 
   show_ButtonsOnScreen(strG_BB,strL_Button_Txt,intU_X+intU_Btn_width*0,intU_Y+intU_Btn_hight*2,intU_Btn_width,intU_Btn_hight);
   //wyświetlanie oscy na wykresie
   if(blnE_Czy_Widoczny)
   {
      show_BB_On();
   }
   else
   {
      show_BB_Off();
      change_Button_State_Off(strG_BB);//guzik tez
   }
   //---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void show_BB_On()
{
   if(blnE_Czy_Gora)
   {
      SetIndexStyle(0,DRAW_LINE,enmE_LiStyle,enmE_LiTh,clrE_linie);
   }
   else
   {
      SetIndexStyle(0,DRAW_NONE);
   }
   if(blnE_Czy_Srodek)
   {
      SetIndexStyle(1,DRAW_LINE,enmE_LiStyle,enmE_LiTh,clrE_linie);
   }
   else
   {
      SetIndexStyle(1,DRAW_NONE);
   }
   if(blnE_Czy_Dol)
   {
      SetIndexStyle(2,DRAW_LINE,enmE_LiStyle,enmE_LiTh,clrE_linie);
   }
   else
   {
      SetIndexStyle(2,DRAW_NONE);
   }
}
//+------------------------------------------------------------------+
void show_BB_Off()
{
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
}
//+------------------------------------------------------------------+
//| Custom indicator DeInit function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(ChartID(),strG_BB);
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
   
   if       (prev_calculated==0)
      intL_BTC=Bars-1;
   
   else if  (enmE_TF!=PERIOD_CURRENT && (arr_bb_u[0]!=arr_bb_u[1] || arr_bb_m[0]!=arr_bb_m[1] || arr_bb_l[0]!=arr_bb_l[1]))
      intL_BTC = calc_i(enmE_TF);
   
   else if  (prev_calculated==rates_total)
      intL_BTC=0;
   
   else
   {
      if(blnE_Czy_Alerts)
      {
         blnG_CzyAlertUp = true;
         blnG_CzyAlertMd = true;
         blnG_CzyAlertDn = true;
      }
      if(enmE_TF!=PERIOD_CURRENT)
      {
         if  (iBarShift(NULL,enmG_TF_2nd,Time[0]) != iBarShift(NULL,enmG_TF_2nd,Time[1]))
            intL_BTC = calc_i(enmE_TF);
      } 
   }

   // obliczenia
   if(enmE_TF==PERIOD_CURRENT)
   {
      for(int i=0;i<=intL_BTC;i++)
      {
         arr_bb_u[i]  = iBands(NULL,0,intE_BB_val,dblE_BB_dev,0,PRICE_MEDIAN,MODE_UPPER,i);
         arr_bb_m[i]  = iBands(NULL,0,intE_BB_val,dblE_BB_dev,0,PRICE_MEDIAN,MODE_MAIN,i);
         arr_bb_l[i]  = iBands(NULL,0,intE_BB_val,dblE_BB_dev,0,PRICE_MEDIAN,MODE_LOWER,i);
      }
   }
   else
   {
      for(int i=0;i<=intL_BTC;i++)
      {
         int intL_HTF = iBarShift(NULL,enmG_TF_2nd,Time[i]);
         arr_bb_u[i]  = iBands(NULL,enmG_TF_2nd,intE_BB_val,dblE_BB_dev,0,PRICE_MEDIAN,MODE_UPPER,intL_HTF);
         arr_bb_m[i]  = iBands(NULL,enmG_TF_2nd,intE_BB_val,dblE_BB_dev,0,PRICE_MEDIAN,MODE_MAIN,intL_HTF);
         arr_bb_l[i]  = iBands(NULL,enmG_TF_2nd,intE_BB_val,dblE_BB_dev,0,PRICE_MEDIAN,MODE_LOWER,intL_HTF);      
      }
   }
   
   //
   manage_BB_Alerts(arr_bb_u,arr_bb_m,arr_bb_l);
   //--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
double calc_i(ENUM_TIMEFRAMES head_TF)
{
   for(int i=1;i<Bars-1;i++)
   if(iBarShift(NULL,head_TF,Time[i])!=iBarShift(NULL,head_TF,Time[i+1]))
   {
      return i+1;
   }
   return 1;
}
//+------------------------------------------------------------------+
bool manage_BB_Alerts(  double      &head_BB_Up[],
                        double      &head_BB_Md[],
                        double      &head_BB_Dn[],
                        const int   head_i = 0)
                        
{
   if(!blnE_Czy_Alerts) return false;

   string strL_Info = Symbol() + " (" + strG_TF_1st + "): " + strG_NazwaIndi + " Says >> ";

   if(blnG_CzyAlertUp)
   if(High[head_i] >= head_BB_Up[head_i] && Low[head_i] < head_BB_Up[head_i])
   {
      Alert(strL_Info," Górna banda");
      blnG_CzyAlertUp = false;
      return true;
   }
   if(blnG_CzyAlertMd)
   if(High[head_i] > head_BB_Md[head_i] && Low[head_i] < head_BB_Md[head_i])
   {
      Alert(strL_Info," Mid banda");
      blnG_CzyAlertMd = false;
      return true;
   }
   if(blnG_CzyAlertDn)
   if(High[head_i] > head_BB_Dn[head_i] && Low[head_i] <= head_BB_Dn[head_i])
   {
      Alert(strL_Info," Dolna banda");
      blnG_CzyAlertDn = false;
      return true;
   }

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
      if(sparam==strG_BB)
      {         
         bool blnL_Button_BB_State = ObjectGetInteger(lngG_ID,strG_BB,OBJPROP_STATE);
         if(!blnL_Button_BB_State)
         {
            show_BB_On();
            change_Button_State_On(strG_BB);
         }
         else
         {
            show_BB_Off();
            change_Button_State_Off(strG_BB);
         }
      }
   }
}