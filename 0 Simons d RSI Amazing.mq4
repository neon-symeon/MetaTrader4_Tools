//+------------------------------------------------------------------+
//|                                       Drunk Rabbit RSI+ 1.00.mq4 |
//|                                     "(c) Szymon Marek 2015-2018" |
//+------------------------------------------------------------------+
#property copyright "(c) Szymon Marek 2016-2018-2022"
#property link      "www.SzymonMarek.com"
#property version   "1.00"
#property strict
#property description "Simon's Drunk Rabbit to czuły na wahnięcia RSI, który szybciej niż DO jest w stanie dostrzec stany lokalnego wyprzedania lub wykupienia."
//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
#property indicator_separate_window
//+------------------------------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 100
//+------------------------------------------------------------------+
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DOT
#property indicator_level1   25
#property indicator_level2   40
#property indicator_level3   50
#property indicator_level4   60
#property indicator_level5   75
//+------------------------------------------------------------------+
#property indicator_color1 clrDodgerBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 5
//---arrows
#property indicator_color2 clrLime
#property indicator_color3 clrRed
//+------------------------------------------------------------------+
#property indicator_buffers 3
//+------------------------------------------------------------------+
double arr_RSI[];
double arr_Arrow_Buy[];
double arr_Arrow_Sell[];
//do zaznaczania prostokątów z wyższych skal czasowych
double arr_RSI_HTF[];
double arr_RSI_HHTF[];

//+------------------------------------------------------------------+
extern ENUM_APPLIED_PRICE  enmE_MetodaCeny               = PRICE_MEDIAN;
extern string              s00="------------------------------"; //--
extern int                 intE_RSI_Base                 = 7;
extern int                 intE_RSI_HTF                  = 0;     //if 0, copy _Base
extern int                 intE_RSI_HHTF                 = 0;     //if 0, copy _Base
extern bool                blnE_Czy_Arrows               = true;  //Czy Strzałki
extern int                 intE_SignalLeverForSell       = 75;
extern bool                blnE_Czy_HTF_OBOS             = true;  //Czy Strefy OB/OS z HTF
extern string              s01="------------------------------"; //--
extern bool                blnE_Czy_Alerts               = false; //Czy Alerty
extern ENUM_TIMEFRAMES     enmE_TF_1st                   = PERIOD_CURRENT;
extern ENUM_TIMEFRAMES     enmE_TF_2nd                   = PERIOD_CURRENT; //Time Frame. Current = Auto
extern ENUM_TIMEFRAMES     enmE_TF_3rd                   = PERIOD_CURRENT; //Time Frame. Current = Auto

//+------------------------------------------------------------------+
//|zmienne globalne;
string sn="//+------------------------------------------------------------------+";
int      intG_RSI_VAL_1, intG_RSI_VAL_2, intG_RSI_VAL_3, intG_RSI_VAL_max;
string   strG_NazwaIndi;
int      intG_WinIdx;
int      intG_Rec_OS_No=0;
int      intG_Rec_OB_No=0;
string   strG_TLB_Button = "TLB_Button";
string   strG_TLT_Button = "TLT_Button";
string   strG_TLD_Button = "TLD_Button";

//multi time frame
ENUM_TIMEFRAMES   enmG_TF_Base, enmG_TF_1st, enmG_TF_2nd, enmG_TF_3rd;
string            strG_TF_1st, strG_TF_2nd, strG_TF_3rd;
//alerts
bool blnG_Czy_Alerts = true;
//
datetime dttG_TL_dt_1 = 0;
datetime dttG_TL_dt_2 = 0;
double   dblG_TL_pr_1 = -1;
double   dblG_TL_pr_2 = -1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- 
   
   intG_RSI_VAL_1 = intE_RSI_Base;
   if(intE_RSI_HTF == 0) intG_RSI_VAL_2 = intE_RSI_Base; else intG_RSI_VAL_2 = intE_RSI_HTF;
   if(intE_RSI_HHTF == 0) intG_RSI_VAL_3 = intE_RSI_Base; else intG_RSI_VAL_3 = intE_RSI_HHTF;
   intG_RSI_VAL_max = MathMax(intG_RSI_VAL_1,MathMax(intG_RSI_VAL_2,intG_RSI_VAL_3));
   
   
   //tylko do wizualizacji nie do dokładności obliczeń
   IndicatorDigits(1);  
   //---
   IndicatorBuffers(5);  
   //ustawienia dla głównego wskaźnika, śrdniej i strzałek
   SetIndexBuffer(0,arr_RSI);             SetIndexStyle(0,DRAW_LINE);                  SetIndexLabel(0,"AMAZING Line");
   SetIndexBuffer(1,arr_Arrow_Buy);       SetIndexStyle(1,DRAW_ARROW,EMPTY_VALUE,1);   SetIndexArrow(1,233);   SetIndexLabel(1,"Drunk Rabbit Buy Signal");   SetIndexEmptyValue(1,0.0);
   SetIndexBuffer(2,arr_Arrow_Sell);      SetIndexStyle(2,DRAW_ARROW,EMPTY_VALUE,1);   SetIndexArrow(2,234);   SetIndexLabel(2,"Drunk Rabbit Sell Signal");  SetIndexEmptyValue(2,0.0);
   
   if(!blnE_Czy_Arrows) {
          SetIndexStyle(1,DRAW_NONE);
          SetIndexStyle(2,DRAW_NONE);}
   
   SetIndexBuffer(3,arr_RSI_HTF);SetIndexBuffer(4,arr_RSI_HHTF);
   
   //--- ograniam time frame'y
   enmG_TF_Base = Period();
                                     enmG_TF_1st = enmE_TF_1st;
   if(enmE_TF_2nd == PERIOD_CURRENT) enmG_TF_2nd = convert_TF_To_H_TF(enmG_TF_Base);    else enmG_TF_2nd = enmE_TF_2nd;
   if(enmE_TF_3rd == PERIOD_CURRENT) enmG_TF_3rd = convert_TF_To_HH_TF(enmG_TF_Base);   else enmG_TF_3rd = enmE_TF_3rd;
   strG_TF_1st = translate_TF(enmG_TF_1st);
   strG_TF_2nd = translate_TF(enmG_TF_2nd);
   strG_TF_3rd = translate_TF(enmG_TF_3rd);
   //nazwa oscylatora
   string strL_Base_Name = "Simon's Amazing RSI|"+translate_Price_type(enmE_MetodaCeny)+"|" + IntegerToString(intG_RSI_VAL_1)+"/"+IntegerToString(intG_RSI_VAL_2)+"/"+IntegerToString(intG_RSI_VAL_3)+"|";
   strG_NazwaIndi=strL_Base_Name;
   if(blnE_Czy_HTF_OBOS)                  strG_NazwaIndi = strG_NazwaIndi + strG_TF_1st + "." + strG_TF_2nd + "."+ strG_TF_3rd;
   if(strG_NazwaIndi != strL_Base_Name)   strG_NazwaIndi = strG_NazwaIndi + "|";
   if(blnE_Czy_Alerts)                    strG_NazwaIndi = strG_NazwaIndi + " ALERTS";
   IndicatorShortName(strG_NazwaIndi);
   //kasowanie starych pasków
   intG_WinIdx=WindowFind(strG_NazwaIndi);
   ObjectsDeleteAll(ChartID(),intG_WinIdx,OBJ_RECTANGLE);
   
   
   //dodaj guzik
   ObjectDelete(strG_TLB_Button);
   ObjectDelete(strG_TLT_Button);
   ObjectDelete(strG_TLD_Button);
   //create_Button(ChartID(),strG_TLB_Button,intG_WinIdx,10,20,24,18,CORNER_LEFT_UPPER,"B");
   //create_Button(ChartID(),strG_TLT_Button,intG_WinIdx,34,20,24,18,CORNER_LEFT_UPPER,"T");
   //create_Button(ChartID(),strG_TLD_Button,intG_WinIdx,10,38,48,18,CORNER_LEFT_UPPER,"Delete");
   
   //---koniec
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
   int intL_BTC = rates_total - prev_calculated + 1;     
   if       (prev_calculated==0)             intL_BTC=Bars-intG_RSI_VAL_max-1;   
   else if  (prev_calculated==rates_total)   intL_BTC=0;
   else
   { 
      //do alertów
      blnG_Czy_Alerts = true;
      //
      if(blnE_Czy_HTF_OBOS){
      if  (iBarShift(NULL,enmG_TF_3rd,Time[0]) != iBarShift(NULL,enmG_TF_3rd,Time[0]))
      {
         for(int i=2;i<Bars-intG_RSI_VAL_3;i++)
         if(iBarShift(NULL,enmG_TF_3rd,Time[i])!=iBarShift(NULL,enmG_TF_3rd,Time[i+1]))
         {
            intL_BTC  = i+1;
            //Alert("TF=",strG_TF_1st,"; ",Symbol()," ",strG_TF_3rd," ",strG_NazwaIndi," Bars To Calculate: ",intL_BTC);            
            break;
         }
      } 
      else if  (iBarShift(NULL,enmG_TF_2nd,Time[0]) != iBarShift(NULL,enmG_TF_2nd,Time[1]))
      {
         for(int i=2;i<Bars-intG_RSI_VAL_2;i++)
         if(iBarShift(NULL,enmG_TF_2nd,Time[i])!=iBarShift(NULL,enmG_TF_2nd,Time[i+1]))
         {
            intL_BTC  = i+1;
            //Alert("TF=",strG_TF_1st,"; ",Symbol()," ",strG_TF_3rd," ",strG_NazwaIndi," Bars To Calculate: ",intL_BTC);            
            break;
         }
      } }
   }
   //oblicza RSI dla MEDIANY ceny
   for(int i=0;i<=intL_BTC;i++)
   {
      int intL_BarShift = iBarShift(NULL,enmG_TF_1st,Time[i]);
      arr_RSI[i]=iRSI(NULL,enmG_TF_1st,intG_RSI_VAL_1,enmE_MetodaCeny,intL_BarShift);
   }
   //arrows
   if(blnE_Czy_Arrows) {
   int intL_dist = 7;
   int intL_position_Sell = 95;
   int intL_position_Buy  = 100-intL_position_Sell;
   int intL_LowerLevel = 100-intE_SignalLeverForSell;
   //
   for(int i=intL_BTC;i>=0;i--)
   {
      arr_Arrow_Sell[i] = 0;
      
      if (arr_RSI[i+1] >= intE_SignalLeverForSell && arr_RSI[i] < intE_SignalLeverForSell)
      {
            arr_Arrow_Sell[i] = intL_position_Sell;
      }
   }
   //
   for(int i=intL_BTC;i>=0;i--)
   {
   
      arr_Arrow_Buy[i] = 0;
      if (arr_RSI[i+1] <= intL_LowerLevel && arr_RSI[i] > intL_LowerLevel)
      {
            arr_Arrow_Buy[i] = intL_position_Buy;
      }         
   } }
   //
   if(prev_calculated!=rates_total)
   {
      //--- do pasków
      if(blnE_Czy_HTF_OBOS){
      for(int i=0;i<=intL_BTC;i++) {
         int intL_2_TF  = iBarShift(NULL,enmG_TF_2nd,Time[i]);
         arr_RSI_HTF[i] = iRSI(NULL,enmG_TF_2nd,intG_RSI_VAL_2,enmE_MetodaCeny,intL_2_TF); }
      //
      for(int i=0;i<=intL_BTC;i++) {
         int intL_3_TF   = iBarShift(NULL,enmG_TF_3rd,Time[i]);
         arr_RSI_HHTF[i] = iRSI(NULL,enmG_TF_3rd,intG_RSI_VAL_3,enmE_MetodaCeny,intL_3_TF); } }      
      //
      OBOS();
   }
   //
   manage_Alerts();
   
   //--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
bool OBOS()
//20150913 zacząłem a teraz (20150914) kontynuuję
//prostokąty OB/OS
{  

   ObjectsDeleteAll(ChartID(),intG_WinIdx,OBJ_RECTANGLE);
   
   if(!blnE_Czy_HTF_OBOS) return false;

   int      intL_TimeEnd;
   int      intL_TimeBeg;
   double   dblL_ValBeg=88;
   double   dblL_ValEnd=82;
   int      intL_OB = 80;        if (intL_OB<80) intL_OB = 80;// nie mniej niż 80
   int      intL_OS = 100- 80;   if (intL_OS>20) intL_OS = 20;// analogicznie nie więcej niż 20
      int      intL_Bull_TimeEnd;
   int      intL_Bull_TimeBeg;
   double   dblL_Bull_ValBeg;
   double   dblL_Bull_ValEnd;
   color    clrL_bulls = clrLime,   clrL_bears = clrRed;
   
   if(strG_TF_1st!=strG_TF_2nd)
   {
   for (int i=Bars-20;i>=0;i--)//znajduję piewrszy punkt
   {
      //znajdowanie pierwszych parametrów
      if(arr_RSI_HTF[i]>=intL_OB)
      {          
         intL_TimeBeg=i;
         for (int j=i-1;j>=0;j--)// znajduję drugi punkt
         if(arr_RSI_HTF[j]<intL_OB || j == 0)
         {
            intL_TimeEnd=j;
            i=j;
            break;
         }
      // - - - rysowanie prostokąta
         if(intL_TimeBeg>intL_TimeEnd)
         {
            //licznik prostokątów OB
            intG_Rec_OB_No++;
            
            string strL_NoOf_OB_Bar=StringConcatenate(IntegerToString(intG_Rec_OB_No)," ",IntegerToString(MathRand()));
            string strL_RecName=StringConcatenate("Hot OB#",strG_TF_2nd," ",strL_NoOf_OB_Bar);
            string strL_RecName2=StringConcatenate(strL_RecName,"|");
      
            //czasy początku i końca prostokąta
            datetime dttL_TimeBeg=Time[intL_TimeBeg];
            datetime dttL_TimeEnd=Time[intL_TimeEnd];
      
            //wypełnienie
            ObjectCreate(ChartID(),strL_RecName2,OBJ_RECTANGLE,intG_WinIdx,dttL_TimeBeg,dblL_ValBeg,dttL_TimeEnd,dblL_ValEnd); 
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_COLOR,clrL_bears);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_WIDTH,0);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_SELECTABLE,false); 
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_SELECTED,false);                
          }
      }
   }
  
   dblL_Bull_ValBeg=12;
   dblL_Bull_ValEnd=18;

   for (int i=Bars-20;i>=0;i--)//znajduję piewrszy punkt
   {
      //znajdowanie pierwszych parametrów
      if(arr_RSI_HTF[i]<=intL_OS)
      {        
         intL_Bull_TimeBeg=i;
         for (int j=i-1;j>=0;j--)// znajduję drugi punkt
         if(arr_RSI_HTF[j]>intL_OS || j == 0)
         {
            intL_Bull_TimeEnd=j;
            i=j;
            break;
            
         }
         
      // - - - rysowanie prostokąta
         if(intL_Bull_TimeBeg>intL_Bull_TimeEnd)
         {  
            //licznik prostokątów OS
            intG_Rec_OS_No++;

            string strL_NoOf_OS_Bar=StringConcatenate(IntegerToString(intG_Rec_OS_No)," ",IntegerToString(MathRand()));
            string strL_RecName=StringConcatenate("Cold OS#",strG_TF_2nd," ",strL_NoOf_OS_Bar);
            string strL_RecName2=StringConcatenate(strL_RecName,"|");   
      
            //czasy początku i końca prostokąta
            datetime dttL_TimeBeg=Time[intL_Bull_TimeBeg];
            datetime dttL_TimeEnd=Time[intL_Bull_TimeEnd];
      
            //wypełnienie
            ObjectCreate(ChartID(),strL_RecName2,OBJ_RECTANGLE,intG_WinIdx,dttL_TimeBeg,dblL_Bull_ValBeg,dttL_TimeEnd,dblL_Bull_ValEnd); 
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_COLOR,clrL_bulls);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_WIDTH,0);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_SELECTABLE,false); 
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_SELECTED,false);             
         }
      }
   }   
   dblL_ValBeg=86;
   dblL_ValEnd=83;
   clrL_bulls = clrGreen; clrL_bears = clrBrown;
   }

   if(strG_TF_2nd!=strG_TF_3rd)
   {
   for (int i=Bars-20;i>=0;i--)//znajduję piewrszy punkt
   {
      //znajdowanie pierwszych parametrów
      if(arr_RSI_HHTF[i]>=intL_OB)
      {          
         intL_TimeBeg=i;
         for (int j=i-1;j>=0;j--)// znajduję drugi punkt
         if(arr_RSI_HHTF[j]<intL_OB || j == 0)
         {
            intL_TimeEnd=j;
            i=j;
            break;
         }
      // - - - rysowanie prostokąta
         if(intL_TimeBeg>intL_TimeEnd)
         {
            //licznik prostokątów OB
            intG_Rec_OB_No++;
            
            string strL_NoOf_OB_Bar=StringConcatenate(IntegerToString(intG_Rec_OB_No)," ",IntegerToString(MathRand()));
            string strL_RecName=StringConcatenate("Hot OB#",strG_TF_3rd," ",strL_NoOf_OB_Bar);
            string strL_RecName2=StringConcatenate(strL_RecName,"|");
      
            //czasy początku i końca prostokąta
            datetime dttL_TimeBeg=Time[intL_TimeBeg];
            datetime dttL_TimeEnd=Time[intL_TimeEnd];
      
            //wypełnienie
            ObjectCreate(ChartID(),strL_RecName2,OBJ_RECTANGLE,intG_WinIdx,dttL_TimeBeg,dblL_ValBeg,dttL_TimeEnd,dblL_ValEnd); 
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_COLOR,clrL_bears);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_WIDTH,0);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_SELECTABLE,false); 
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_SELECTED,false);                
          }
      }
   }
   
   dblL_Bull_ValBeg=14;
   dblL_Bull_ValEnd=17;

   for (int i=Bars-20;i>=0;i--)//znajduję piewrszy punkt
   {
      //znajdowanie pierwszych parametrów
      if(arr_RSI_HHTF[i]<=intL_OS)
      {        
         intL_Bull_TimeBeg=i;
         for (int j=i-1;j>=0;j--)// znajduję drugi punkt
         if(arr_RSI_HHTF[j]>intL_OS || j == 0)
         {
            intL_Bull_TimeEnd=j;
            i=j;
            break;
            
         }
         
      // - - - rysowanie prostokąta
         if(intL_Bull_TimeBeg>intL_Bull_TimeEnd)
         {  
            //licznik prostokątów OS
            intG_Rec_OS_No++;

            string strL_NoOf_OS_Bar=StringConcatenate(IntegerToString(intG_Rec_OS_No)," ",IntegerToString(MathRand()));
            string strL_RecName=StringConcatenate("Cold OS#",strG_TF_3rd," ",strL_NoOf_OS_Bar);
            string strL_RecName2=StringConcatenate(strL_RecName,"|");   
      
            //czasy początku i końca prostokąta
            datetime dttL_TimeBeg=Time[intL_Bull_TimeBeg];
            datetime dttL_TimeEnd=Time[intL_Bull_TimeEnd];
      
            //wypełnienie
            ObjectCreate(ChartID(),strL_RecName2,OBJ_RECTANGLE,intG_WinIdx,dttL_TimeBeg,dblL_Bull_ValBeg,dttL_TimeEnd,dblL_Bull_ValEnd); 
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_COLOR,clrL_bulls);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_WIDTH,0);
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_SELECTABLE,false); 
            ObjectSetInteger(ChartID(),strL_RecName2,OBJPROP_SELECTED,false);             
         }
      }
   }
   }
   return true;
}
//+------------------------------------------------------------------+
//+                        Alert Management                          +
//+------------------------------------------------------------------+
bool manage_Alerts()
{
//20160829
//dopisane na prosbe Adama :)
   if(!blnE_Czy_Alerts) return false;
   if(!blnG_Czy_Alerts) return false;
   
   
   string strL_Info = Symbol() + " (" + strG_TF_1st + "): " + strG_NazwaIndi + " Says >> ";
   
   if(arr_RSI[1]>80 && arr_RSI[0]<80)
   {
      Alert(strL_Info,"SELL");
      blnG_Czy_Alerts = false;
      return true;
   }
   if(arr_RSI[1]<(100-80) && arr_RSI[0]>(100-80) )
   {
      Alert(strL_Info,"BUY");
      blnG_Czy_Alerts = false;
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
//   bool blnL_Button_TL_State = ObjectGetInteger(ChartID(),strG_TL_Button,OBJPROP_STATE);

//   //20190105 pRODUKCJA W PROSZKU ALE COŚTAM JUŻ DZIAŁA LINIE RYSUJE PROBLEM ZE ZACZYNA NA GUZIKU UPS
//   if( id == CHARTEVENT_CLICK)
//   {  
//      if(blnL_Button_TL_State)
//      {    
//         //--- Prepare variables 
//         int      intL_x     =(int)lparam; 
//         int      intL_y     =(int)dparam; 
//         datetime dttL_dt    =0; 
//         double   dblL_price =0; 
//         int      intL_w=0; 
//         if(ChartXYToTimePrice(0,intL_x,intL_y,intL_w,dttL_dt,dblL_price))
//         {
//            if       (dttG_TL_dt_1 == 0) dttG_TL_dt_1 = dttL_dt;
//            else if  (dttG_TL_dt_2 == 0) dttG_TL_dt_2 = dttL_dt;
//
//            if       (dblG_TL_pr_1 == -1)dblG_TL_pr_1 = dblL_price;
//            else if  (dblG_TL_pr_2 == -1)dblG_TL_pr_2 = dblL_price;
//
//
//            if(dblG_TL_pr_1!=-1 && dblG_TL_pr_2!=-1)
//            {
//               Alert("rysuje linie trendu:", intL_w," ",dttG_TL_dt_1," ",dblG_TL_pr_1," ",dttG_TL_dt_2," ",dblG_TL_pr_2);
//               create_Trend(intL_w,"TL",dttG_TL_dt_1,dblG_TL_pr_1,dttG_TL_dt_2,dblG_TL_pr_2);
//               dttG_TL_dt_1 = 0;
//               dttG_TL_dt_2 = 0;
//               dblG_TL_pr_1 = -1;
//               dblG_TL_pr_2 = -1;
//            }
//            Alert("Button is ", blnL_Button_TL_State," window: ", intL_w," to x: ",intL_x," y: ",intL_y," date ",dttL_dt," price=",dblL_price);
//         }
//
//      }
//   }
   if( id == CHARTEVENT_OBJECT_CLICK )
   {
      
      if(sparam==strG_TLB_Button)
      {
      //bold line
         bool blnL_Button_TLB_State = ObjectGetInteger(ChartID(),strG_TLB_Button,OBJPROP_STATE);
              
         if(blnL_Button_TLB_State)
         {
            add_T_Line(STYLE_SOLID,2);
            ObjectSetInteger(ChartID(),strG_TLB_Button,OBJPROP_STATE,false);
         }
         else
         {
            ObjectSetInteger(ChartID(),strG_TLB_Button,OBJPROP_STATE,false);
         }
      }
      if(sparam==strG_TLT_Button)
      {
      //thin line
      }
      if(sparam==strG_TLD_Button)
      {
      //delete
      }
   
   }

   
}
//+------------------------------------------------------------------+
bool add_T_Line(  const ENUM_LINE_STYLE head_style =  STYLE_SOLID,
                  const int             head_thick =  1)
{
   string strL_Line_Name = "AmazinG TL ";
   
   intG_WinIdx=WindowFind(strG_NazwaIndi);
   for(int i=0;i<999;i++)
   {
      string strL_X_LineName = StringConcatenate(strL_Line_Name,IntegerToString(i));
      if(ObjectFind(ChartID(),strL_X_LineName)<0)
      if(create_Trend(intG_WinIdx,strL_X_LineName,Time[20],55,Time[0],60,clrGold,head_style,head_thick,true,true,false,false))
      {
         ObjectSetInteger(ChartID(),strL_X_LineName,OBJPROP_RAY_RIGHT,true);
         ObjectSetInteger(ChartID(),strL_X_LineName,OBJPROP_SELECTABLE,true); 
         ObjectSetInteger(ChartID(),strL_X_LineName,OBJPROP_SELECTED,true); 
         ObjectSetInteger(ChartID(),strL_X_LineName,OBJPROP_HIDDEN,false);          
         return true;
      }
   }
   return false;
}