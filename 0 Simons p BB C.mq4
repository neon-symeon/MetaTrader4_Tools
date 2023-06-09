//20181219  centurion powraca szczególnie m5 ciekawie wygląda tutaj
//20181201  chmury i zawsze 50-55
//20181125  wprowadziłem poprawki i stylistyczne drobne zmiany, wykasowałem limit czasowy
//20160619  metoda ceny na sztywno. opisy ukrywają metodę ceny
//20150905  kolejne zmiany
//20150728  zmieniłem sposób przeliczęń wprowadzając prev_calculated i to jest b dobre
//+------------------------------------------------------------------+
#property copyright "(c)Szymon Marek 2018"
#property link      "www.SzymonMarek.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property description "Simon's Centurion Bands"
#property description " "
#property description "Centurion Bands określa standardowe ramy głównego trendu z użyciem średniej SMA100"
#property description " "
#property description "A Bollinger Band® is a set of lines plotted two standard deviations (positively and negatively) away from a simple moving average of the security's price. A Bollinger Band®, developed by famous technical trader John Bollinger."
//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
#property indicator_buffers 7
//+------------------------------------------------------------------+
double arr_bb_u_0[],arr_bb_u_1[],arr_bb_u_2[];
double arr_bb_m_1[];
double arr_bb_l_0[],arr_bb_l_1[],arr_bb_l_2[];
//+------------------------------------------------------------------+
//+ zmienne globalne
//+------------------------------------------------------------------+
long     lngG_ID        = ChartID();   //chart ID
string   strG_Symbol    = Symbol();
string   strG_NazwaIndi;
string   strG_BB        = "BB 100"; //nazwa Buttona
int      intG_BB_0      = 77;
extern int intG_BB_1      = 100;
int      intG_BB_2      = 123;
bool     blnG_CzyAlertUp = true;
bool     blnG_CzyAlertMd = true;
bool     blnG_CzyAlertDn = true;
ENUM_TIMEFRAMES   enmG_TF_1st = Period();
string            strG_TF_1st = translate_TF(enmG_TF_1st);

//+------------------------------------------------------------------+
//globalne zewnętrzne
//+------------------------------------------------------------------+
extern string        s0 = "--- Widoczność Oscylatora na Wykresie ---";
extern bool          blnE_Czy_Widoczny = true;
extern string        s0_1 = "--- Widoczność Linii ---";
extern bool          blnE_Czy_Centurion_Lines   = true;
extern bool          blnE_Czy_Extra_Lines       = false;
extern string        s0_2 = "--- Widoczność poszczególnych grup ---";
extern bool          blnE_Czy_Gora     = true;
extern bool          blnE_Czy_Srodek   = true;
extern bool          blnE_Czy_Dol      = true;
extern string        s00="------------------------------";
extern bool          blnE_Czy_Alerts  = false; //Czy Alerty
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- nazwa
   strG_NazwaIndi = "Simons BB Centurion";
   IndicatorShortName(strG_NazwaIndi);   
   //--- buforowanie
   SetIndexBuffer(0,arr_bb_u_0);    SetIndexEmptyValue(0,0.0); SetIndexLabel(0,"U|"+IntegerToString(intG_BB_0));
   SetIndexBuffer(1,arr_bb_u_1);    SetIndexEmptyValue(1,0.0); SetIndexLabel(1,"U|"+IntegerToString(intG_BB_1));
   SetIndexBuffer(2,arr_bb_u_2);    SetIndexEmptyValue(2,0.0); SetIndexLabel(2,"U|"+IntegerToString(intG_BB_2));
   //
   SetIndexBuffer(3,arr_bb_m_1);    SetIndexEmptyValue(3,0.0); SetIndexLabel(3,"M|"+IntegerToString(intG_BB_1));
   //
   SetIndexBuffer(4,arr_bb_l_0);    SetIndexEmptyValue(4,0.0); SetIndexLabel(4,"L|"+IntegerToString(intG_BB_0));
   SetIndexBuffer(5,arr_bb_l_1);    SetIndexEmptyValue(5,0.0); SetIndexLabel(5,"L|"+IntegerToString(intG_BB_1));
   SetIndexBuffer(6,arr_bb_l_2);    SetIndexEmptyValue(6,0.0); SetIndexLabel(6,"L|"+IntegerToString(intG_BB_2));
   //-- wyświetlanie buttona na wykresie
   show_ButtonsOnScreen(strG_BB,"C",intU_X+intU_Btn_width*3,intU_Y+intU_Btn_hight*2,intU_Btn_width,intU_Btn_hight);
   //wyświetlanie na wykresie
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
   if(blnE_Czy_Centurion_Lines)
   {
      SetIndexStyle(1,DRAW_LINE,STYLE_DASHDOT,1,clrSilver);
      SetIndexStyle(3,DRAW_LINE,STYLE_DASHDOT,1,clrSilver);
      SetIndexStyle(5,DRAW_LINE,STYLE_DASHDOT,1,clrSilver);
   }
   else
   {
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);
   }
   if(blnE_Czy_Extra_Lines)
   {
      SetIndexStyle(0,DRAW_LINE,STYLE_DASHDOTDOT,1,clrGray);
      SetIndexStyle(2,DRAW_LINE,STYLE_DASHDOTDOT,1,clrGray);
      SetIndexStyle(4,DRAW_LINE,STYLE_DASHDOTDOT,1,clrGray);
      SetIndexStyle(6,DRAW_LINE,STYLE_DASHDOTDOT,1,clrGray);
   }
   else
   {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(6,DRAW_NONE);
   }
   if(!blnE_Czy_Gora)
   {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
   }
   if(!blnE_Czy_Srodek)
   {
      SetIndexStyle(3,DRAW_NONE);
   }
   if(!blnE_Czy_Dol)
   {
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);
      SetIndexStyle(6,DRAW_NONE);
   }
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
   //if(ObjectFind(ChartID(),strG_BB)>-1) Alert("Znalazłem w On Calculate ",strG_BB);
   //else Alert("nie Znalazłem ",GetLastError());
   
   int intL_BTC;

   if (prev_calculated==0)                //dla pierwszego przelotu
   {
      intL_BTC=Bars-1;
   } 
   else if  (prev_calculated==rates_total)//przelicza tylko ostatni
   {
      intL_BTC=0; 
   }
   else
   {
      //control alerts
      if(blnE_Czy_Alerts)
      {
         blnG_CzyAlertUp = true;
         blnG_CzyAlertMd = true;
         blnG_CzyAlertDn = true;
      }
      //
      intL_BTC=rates_total-prev_calculated+1;
   }

   for(int i=0;i<=intL_BTC;i++)
   {
      
      arr_bb_u_0[i]  = iBands(NULL,0,intG_BB_0,2,0,PRICE_MEDIAN,MODE_UPPER,i);
      arr_bb_u_1[i]  = iBands(NULL,0,intG_BB_1,2,0,PRICE_MEDIAN,MODE_UPPER,i);
      arr_bb_u_2[i]  = iBands(NULL,0,intG_BB_2,2,0,PRICE_MEDIAN,MODE_UPPER,i);

      arr_bb_m_1[i]  = iBands(NULL,0,intG_BB_1,2,0,PRICE_MEDIAN,MODE_MAIN,i);

      arr_bb_l_0[i]  = iBands(NULL,0,intG_BB_0,2,0,PRICE_MEDIAN,MODE_LOWER,i);
      arr_bb_l_1[i]  = iBands(NULL,0,intG_BB_1,2,0,PRICE_MEDIAN,MODE_LOWER,i);
      arr_bb_l_2[i]  = iBands(NULL,0,intG_BB_2,2,0,PRICE_MEDIAN,MODE_LOWER,i);

   }
   //
   manage_BB_Alerts(arr_bb_u_1,arr_bb_m_1,arr_bb_l_1);
   //--- return value of prev_calculated for next call
   return(rates_total);
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