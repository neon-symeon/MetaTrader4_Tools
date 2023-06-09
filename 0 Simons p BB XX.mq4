//20181227  bb10 jako esencja bb. echa tego na mniejszych skalach generują wyższe bb
//+------------------------------------------------------------------+
#property copyright "(c)Szymon Marek 2018"
#property link      "www.SzymonMarek.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property description "Simon's XX Bands"
#property description " "
#property description "X Bands określa standardowe ramy kierunku ruchu ceny z użyciem średniej SMAw0. Możliwe moddyfikacje docelowych ustawień."
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
double arr_bb_u_1[], arr_bb_m_1[],arr_bb_l_1[];
//+------------------------------------------------------------------+
//+ zmienne globalne
//+------------------------------------------------------------------+
long              lngG_ID        = ChartID();   //chart ID
string            strG_Symbol    = Symbol();
string            strG_NazwaIndi;
string            strG_BB_XX        = "BB 20"; //nazwa Buttona
ENUM_TIMEFRAMES   enmG_TF_1st = Period();
string            strG_TF_1st = translate_TF(enmG_TF_1st);
ENUM_TIMEFRAMES   enmG_TF_2nd;
string            strG_TF_2nd="";

bool     blnG_CzyAlertUp = true;
bool     blnG_CzyEmailUp = true;
bool     blnG_CzyAlertMd = true;
bool     blnG_CzyEmailMd = true;
bool     blnG_CzyAlertDn = true;
bool     blnG_CzyEmailDn = true;

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
extern ENUM_LINE_STYLE        enmE_LiStyle_B = STYLE_SOLID; //Styl Band
extern ENUM_LINE_STYLE        enmE_LiStyle_M = STYLE_DOT;   //Styl Linii Środkowej
extern color                  clrE_linie     = clrGold;     //Kolor Linii
extern ENUM_Lines_Thickness   enmE_LiTh      = thick_1;     //Grubość Linii
extern string        s3 = "--- *** Parametry Wstęgi *** ---";
extern int                    intE_BB_val    = 18;
extern double                 dblE_BB_dev    = 2.0;
extern string        s4 = "--- Fixed Time Frame ---";
extern ENUM_TIMEFRAMES        enmE_TF = PERIOD_CURRENT;
extern string        s00="------------------------------";  //Czy Alerty
extern bool                   blnE_CzyAlertUp = false;
extern bool                   blnE_CzyAlertMd = false;
extern bool                   blnE_CzyAlertDn = false;
extern string        s01="------------------------------";  //Czy Emaile
extern bool                   blnE_CzyEmailUp = false;
extern bool                   blnE_CzyEmailMd = false;
extern bool                   blnE_CzyEmailDn = false;


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
   strG_NazwaIndi = "Simons BB XX";
   if(enmE_TF!=PERIOD_CURRENT)   strG_NazwaIndi = strG_NazwaIndi + " |" + strG_TF_2nd + "(" + IntegerToString(intE_BB_val)+","+DoubleToStr(dblE_BB_dev,2)+")";
   if(blnE_CzyAlertUp || blnE_CzyAlertMd || blnE_CzyAlertDn)           strG_NazwaIndi = strG_NazwaIndi + " ALERTS";
   IndicatorShortName(strG_NazwaIndi);   
   //--- buforowanie
   SetIndexBuffer(0,arr_bb_u_1);    SetIndexEmptyValue(0,0.0); SetIndexLabel(0,"U|"+IntegerToString(intE_BB_val));
   SetIndexBuffer(1,arr_bb_m_1);    SetIndexEmptyValue(1,0.0); SetIndexLabel(1,"M|"+IntegerToString(intE_BB_val));
   SetIndexBuffer(2,arr_bb_l_1);    SetIndexEmptyValue(2,0.0); SetIndexLabel(2,"L|"+IntegerToString(intE_BB_val));
   //-- wyświetlanie buttona na wykresie
   string strL_Button_Txt = "2";
   if(intE_BB_val!=18 || enmE_TF!=PERIOD_CURRENT) strL_Button_Txt = "2*"; 
   show_ButtonsOnScreen(strG_BB_XX,strL_Button_Txt,intU_X+intU_Btn_width*1,intU_Y+intU_Btn_hight*2,intU_Btn_width,intU_Btn_hight);
   //wyświetlanie oscy na wykresie
   if(blnE_Czy_Widoczny)
   {
      show_BB_On();
   }
   else
   {
      show_BB_Off();
      change_Button_State_Off(strG_BB_XX);//guzik tez
   }
   //---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void show_BB_On()
{
   if(blnE_Czy_Gora)
   {
      SetIndexStyle(0,DRAW_LINE,enmE_LiStyle_B,enmE_LiTh,clrE_linie);
   }
   else
   {
      SetIndexStyle(0,DRAW_NONE);
   }
   if(blnE_Czy_Srodek)
   {
      SetIndexStyle(1,DRAW_LINE,enmE_LiStyle_M,enmE_LiTh,clrE_linie);
   }
   else
   {
      SetIndexStyle(1,DRAW_NONE);
   }
   if(blnE_Czy_Dol)
   {
      SetIndexStyle(2,DRAW_LINE,enmE_LiStyle_B,enmE_LiTh,clrE_linie);
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
   ObjectDelete(ChartID(),strG_BB_XX);
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
      //control alerts
         if(blnE_CzyAlertUp) blnG_CzyAlertUp = true; else blnG_CzyAlertUp = false; 
         if(blnE_CzyAlertMd) blnG_CzyAlertMd = true; else blnG_CzyAlertMd = false; 
         if(blnE_CzyAlertDn) blnG_CzyAlertDn = true; else blnG_CzyAlertDn = false; 
         
         if(blnE_CzyEmailUp) blnG_CzyEmailUp = true; else blnG_CzyEmailUp = false; 
         if(blnE_CzyEmailMd) blnG_CzyEmailMd = true; else blnG_CzyEmailMd = false; 
         if(blnE_CzyEmailDn) blnG_CzyEmailDn = true; else blnG_CzyEmailDn = false; 

      //
      if(enmE_TF!=PERIOD_CURRENT)
      if(iBarShift(NULL,enmG_TF_2nd,Time[0]) != iBarShift(NULL,enmG_TF_2nd,Time[1]))
      {
         for(int i=2;i<Bars-1;i++)
         if(iBarShift(NULL,enmG_TF_2nd,Time[i])!=iBarShift(NULL,enmG_TF_2nd,Time[i+1]))
         {
            intL_BTC  = i+1;
            ENUM_TIMEFRAMES enmL_TF = Period();
            //Alert("TF=",translate_TF(enmL_TF),"; ",strG_Symbol," ",strG_TF_2nd," ",strG_NazwaIndi," Bars To Calculate: ",intL_BTC);
            break;
         }
      } 
   }
   //
   if(enmE_TF==PERIOD_CURRENT)
   {
      for(int i=0;i<=intL_BTC;i++)
      {
         arr_bb_u_1[i]  = iBands(NULL,0,intE_BB_val,dblE_BB_dev,0,PRICE_MEDIAN,MODE_UPPER,i);
         arr_bb_m_1[i]  = iBands(NULL,0,intE_BB_val,dblE_BB_dev,0,PRICE_MEDIAN,MODE_MAIN,i);
         arr_bb_l_1[i]  = iBands(NULL,0,intE_BB_val,dblE_BB_dev,0,PRICE_MEDIAN,MODE_LOWER,i);
      }
   }
   else
   {
      for(int i=0;i<=intL_BTC;i++)
      {
         int intL_HTF = iBarShift(NULL,enmG_TF_2nd,Time[i]);
         arr_bb_u_1[i]  = iBands(NULL,enmG_TF_2nd,intE_BB_val,dblE_BB_dev,0,PRICE_MEDIAN,MODE_UPPER,intL_HTF);
         arr_bb_m_1[i]  = iBands(NULL,enmG_TF_2nd,intE_BB_val,dblE_BB_dev,0,PRICE_MEDIAN,MODE_MAIN,intL_HTF);
         arr_bb_l_1[i]  = iBands(NULL,enmG_TF_2nd,intE_BB_val,dblE_BB_dev,0,PRICE_MEDIAN,MODE_LOWER,intL_HTF);      
      }
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
   string strL_Info = Symbol() + " (" + strG_TF_1st + "): " + strG_NazwaIndi + " Says >> ";

   if(High[head_i] >= head_BB_Up[head_i] && Low[head_i] < head_BB_Up[head_i])
   {
      if(blnE_CzyEmailUp && blnG_CzyEmailUp)
      {
         SendMail("ALERT: " + strL_Info, "Wygląda na potencjalny Sell Signal");
         Alert(strL_Info," Górna banda");
      }
      else if(blnE_CzyAlertUp && blnG_CzyAlertUp)
         Alert(strL_Info," Górna banda");
      
      blnG_CzyAlertUp = false;
      blnG_CzyEmailUp = false;
      return true;
   }
   
   if(High[head_i] > head_BB_Md[head_i] && Low[head_i] < head_BB_Md[head_i])
   {
      if(blnE_CzyEmailMd && blnG_CzyEmailMd)
      {
         SendMail("ALERT: " + strL_Info, "Środek wstęgi zaliczony");
         Alert(strL_Info," Mid banda");
      }
      else if(blnE_CzyAlertMd && blnG_CzyAlertMd)
         Alert(strL_Info," Mid banda");
      
      blnG_CzyAlertMd = false;
      blnG_CzyEmailMd = false;
      return true;
   }

   if(High[head_i] > head_BB_Dn[head_i] && Low[head_i] <= head_BB_Dn[head_i])
   {
      if(blnE_CzyEmailDn && blnG_CzyEmailDn)
      {
         SendMail("ALERT: " + strL_Info, "Wygląda na potencjalny Baj Signal");
         Alert(strL_Info," Dolna  banda");
      }
      else if(blnE_CzyAlertDn && blnG_CzyAlertDn)
         Alert(strL_Info," Dolna banda");
      
      blnG_CzyAlertDn = false;
      blnG_CzyEmailDn = false;
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
      if(sparam==strG_BB_XX)
      {         
         bool blnL_Button_BB_State = ObjectGetInteger(lngG_ID,strG_BB_XX,OBJPROP_STATE);
         if(!blnL_Button_BB_State)
         {
            show_BB_On();
            change_Button_State_On(strG_BB_XX);
         }
         else
         {
            show_BB_Off();
            change_Button_State_Off(strG_BB_XX);
         }
      }
   }
}