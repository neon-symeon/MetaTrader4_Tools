//+------------------------------------------------------------------+
//|                                               Ultra RSI 1.00.mq4 |
//|                                          "(c) Szymon Marek 2020" |
//+------------------------------------------------------------------+
#property copyright "(c) Szymon Marek 2016-2023"
#property link      "www.SzymonMarek.com"
#property version   "2.00"
#property strict
#property description ""
//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
#property indicator_separate_window
//+------------------------------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 100
////+----------------------------------------------------------------+
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DOT
#property indicator_level1   10
#property indicator_level2   20
#property indicator_level3   30
#property indicator_level4   40
#property indicator_level5   50
#property indicator_level6   60
#property indicator_level7   70
#property indicator_level8   80
#property indicator_level9   90
//+------------------------------------------------------------------+
enum ENUMS_RSI_ULTRA_Val
{
   rsi_02 = 2,
   rsi_03 = 3,
   rsi_04 = 4,
   rsi_05 = 05,
   rsi_07 = 7,
   rsi_08 = 8,
   rsi_11 = 11,
   rsi_13 = 13,
   rsi_14 = 14,
   rsi_18 = 18,
   rsi_21 = 21,
   rsi_29 = 29
};
//+------------------------------------------------------------------+
#property indicator_color1 clrDodgerBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
//---arrows
#property indicator_color2 clrLime
#property indicator_color3 clrRed
//
#property indicator_color4 clrLime
#property indicator_color5 clrRed
//+------------------------------------------------------------------+
#property indicator_color8 clrSlateBlue
#property indicator_style8 STYLE_DOT
#property indicator_width8 1
//+------------------------------------------------------------------+
#property indicator_buffers 8
//+------------------------------------------------------------------+
double arr_RSI[];
double arr_Fr_Up[];
double arr_Fr_Dn[];
double arr_Fr_Up_Major[];
double arr_Fr_Dn_Major[];
double arr_Fr_Up___[];
double arr_Fr_Dn___[];
double arr_RSI_HTF[];
//+---------------------------------------------------------
extern ENUM_APPLIED_PRICE  enmE_MetodaCeny   = PRICE_MEDIAN;      //Metoda Ceny
extern string              s00="------------------------------";  //--
extern ENUMS_RSI_ULTRA_Val intE_RSI_VAL      = rsi_13;            //RSI Val
extern double              dblE_OBOS_Val     = 0;                 //Strefa Drogo/Tanio 0 - nie rysuje
extern string              s01="------------------------------";
extern bool                blnE_Czy_HTF      = false;             //Czy vast VAL
extern ENUMS_RSI_ULTRA_Val intE_RSI_HTF      = rsi_03;            //RSI Val
extern ENUM_TIMEFRAMES     enmE_HTF          = PERIOD_CURRENT;    //HTF_Period
//+------------------------------------------------------------------+
string   strG_NazwaIndi;;
int      intG_WinIdx;

string   strG_TLB_Button = "TLB_Button_2";
string   strG_TLT_Button = "TLT_Button_2";
string   strG_TLD_Button = "TLD_Button_2";
string   strG_AddSmartLines_Button = "Smart_Button_2";
string   strG_DelSmartLines_Button = "Smart_Button_Del_2";

string   strG_BTC_p1_Label = "p1 COO_2";
string   strG_BTC_p2_Label = "p2 COO_2";

string   strG_30_Line = "30_Line_2";
string   strG_70_Line = "70_Line_2";

//+------------------------------------------------------------------+
int      intG_Dots_Reach = 34;
//+------------------------------------------------------------------+
// stany ważnych guzików
bool  blnG_SmartLines;
//+------------------------------------------------------------------+
//rysowanie linii trendu (testowo)
double      dblG_p_1=0, dblG_p_2=0;
datetime    dtmG_t_1=0, dtmG_t_2=0;            
int         intG_i_1,   intG_i_2;
double      dblG_r_1,   dblG_r_2;
bool        blnG_FirstLine = false;
//+------------------------------------------------------------------+
//multi time frame
ENUM_TIMEFRAMES   enmG_TF_1st, enmG_TF_2nd;
string            strG_TF_1st, strG_TF_2nd;
//
datetime dttG_TL_dt_1 = 0;
datetime dttG_TL_dt_2 = 0;
double   dblG_TL_pr_1 = -1;
double   dblG_TL_pr_2 = -1;


//timeframe multipyer
int intG_BarsBackToCalc=0;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- 
//--- enable CHART_EVENT_MOUSE_MOVE messages 
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);    
   
   //niusanse timeframe
   enmG_TF_1st = Period();
   strG_TF_1st = translate_TF(enmG_TF_1st);
   
   //higher time frame calculation

   //if(blnE_Czy_HTF)
   {
      if(enmE_HTF == PERIOD_CURRENT)   enmG_TF_2nd = enmG_TF_1st;//convert_TF_To_H_TF(enmG_TF_1st);
      else                             enmG_TF_2nd = enmE_HTF;
            
      strG_TF_2nd = translate_TF(enmG_TF_2nd);
   }
   
   //tylko do wizualizacji nie do dokładności obliczeń
   IndicatorDigits(1);  
   //---
   //ustawienia dla głównego wskaźnika i strzałek
   SetIndexBuffer(0,arr_RSI);          SetIndexStyle(0,DRAW_LINE);                                                SetIndexLabel(0,"AMAZING Line");
   SetIndexBuffer(1,arr_Fr_Up);        SetIndexStyle(1,DRAW_ARROW,EMPTY_VALUE,1);         SetIndexArrow(1,167);   SetIndexLabel(1,"Fr_Up");     SetIndexEmptyValue(1,0.0);
   SetIndexBuffer(2,arr_Fr_Dn);        SetIndexStyle(2,DRAW_ARROW,EMPTY_VALUE,1);         SetIndexArrow(2,167);   SetIndexLabel(2,"Fr_Dn");     SetIndexEmptyValue(2,0.0);
   SetIndexBuffer(3,arr_Fr_Up_Major);  SetIndexStyle(3,DRAW_ARROW,EMPTY_VALUE,1);         SetIndexArrow(3,161);   SetIndexLabel(3,"Fr_Up_M");   SetIndexEmptyValue(3,0.0);
   SetIndexBuffer(4,arr_Fr_Dn_Major);  SetIndexStyle(4,DRAW_ARROW,EMPTY_VALUE,1);         SetIndexArrow(4,161);   SetIndexLabel(4,"Fr_Dn_M");   SetIndexEmptyValue(4,0.0);
   SetIndexBuffer(5,arr_Fr_Up___);     SetIndexStyle(5,DRAW_ARROW,STYLE_SOLID,1,clrLime); SetIndexArrow(5,158);   SetIndexLabel(5,"Fr Up____"); SetIndexEmptyValue(5,0.0); 
   SetIndexBuffer(6,arr_Fr_Dn___);     SetIndexStyle(6,DRAW_ARROW,STYLE_SOLID,1,clrRed);  SetIndexArrow(6,158);   SetIndexLabel(6,"Fr Dn____"); SetIndexEmptyValue(6,0.0); 
   if(blnE_Czy_HTF) SetIndexBuffer(7,arr_RSI_HTF);       SetIndexStyle(7,DRAW_LINE);                        SetIndexArrow(7,158);   SetIndexLabel(7,"RSI z "+strG_TF_2nd);       SetIndexEmptyValue(7,0.0); 
   
   
   //nazwa oscylatora
   strG_NazwaIndi = "Ultra RSI 2.0 ("+IntegerToString(intE_RSI_VAL)+")."+strG_TF_1st;
   if(blnE_Czy_HTF)  strG_NazwaIndi = strG_NazwaIndi + " (" + IntegerToString(intE_RSI_HTF)+"}."+strG_TF_2nd;

   IndicatorShortName(strG_NazwaIndi);
   
   intG_WinIdx = WindowFind(strG_NazwaIndi);
   //long intL_CntWndws;
   //ChartGetInteger(0,CHART_WINDOWS_TOTAL,0,intL_CntWndws);
   //Alert(Symbol()," wszystkich okien", intL_CntWndws);
   
   //dodaj guzik
   delete_Buttons();
   create_Button(ChartID(),strG_TLB_Button,           intG_WinIdx,10,20,24,18,CORNER_LEFT_UPPER,"B");
   create_Button(ChartID(),strG_TLT_Button,           intG_WinIdx,34,20,24,18,CORNER_LEFT_UPPER,"T");
   create_Button(ChartID(),strG_TLD_Button,           intG_WinIdx,10,38,48,18,CORNER_LEFT_UPPER,"Delete");
   create_Button(ChartID(),strG_AddSmartLines_Button, intG_WinIdx,58,20,60,18,CORNER_LEFT_UPPER,"Smart TL");
   create_Button(ChartID(),strG_DelSmartLines_Button, intG_WinIdx,58,38,60,18,CORNER_LEFT_UPPER,"Del SmTL");
   
   ////
   //create_Label(0,strG_BTC_TTF_Label,intG_WinIdx,10, 29, CORNER_LEFT_LOWER,"...","Georgia",7,clrWhite);
   //create_Label(0,strG_BTC_HTF_Label,intG_WinIdx,10, 18, CORNER_LEFT_LOWER,"...","Georgia",7,clrWhite);

   create_Label(0,strG_BTC_p1_Label,intG_WinIdx,10, 70, CORNER_LEFT_LOWER," ","Georgia",9,clrGold);
   create_Label(0,strG_BTC_p2_Label,intG_WinIdx,10, 50, CORNER_LEFT_LOWER," ","Georgia",9,clrGold);
   
   //
   delete_Lines();
   if(dblE_OBOS_Val == 0)
   {
      delete_Lines();
   }
   else if(dblE_OBOS_Val>50 && dblE_OBOS_Val<100)
   {
      create_H_Line(intG_WinIdx,strG_30_Line,100-dblE_OBOS_Val,  clrGreen,   STYLE_DOT);
      create_H_Line(intG_WinIdx,strG_70_Line,dblE_OBOS_Val,      clrRed,     STYLE_DOT);       
   }
   else if(dblE_OBOS_Val == 100 || dblE_OBOS_Val == 0)
   {
      //no lines
   }
   else
   {
      Alert("Popraw Wartość strefy OBOS. Powinna być między >50 i <100. Aktualnie wynosi: "+DoubleToStr(dblE_OBOS_Val,1));
   }
   
   Comment("");
      
      //eksperyment z przeliczaniem barów
      if       (enmG_TF_2nd>enmG_TF_1st) intG_BarsBackToCalc = MathRound(enmG_TF_2nd/enmG_TF_1st)+1;
      else if  (enmG_TF_1st>enmG_TF_2nd) intG_BarsBackToCalc = MathRound(enmG_TF_1st/enmG_TF_2nd)+1;
      //Alert(Symbol(),"|Control in Init ",strG_TF_1st,".",strG_TF_2nd,"| BTC HTF: ",IntegerToString(intG_BarsBackToCalc));   
   
   //---koniec
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Comment("");
   delete_Buttons();
}
//+------------------------------------------------------------------+
void delete_Lines()
{
   ObjectDelete(strG_30_Line);
   ObjectDelete(strG_70_Line);
}
//+------------------------------------------------------------------+
void delete_Buttons()
{
   //dodaj guzik
   ObjectDelete(strG_TLB_Button);
   ObjectDelete(strG_TLT_Button);
   ObjectDelete(strG_TLD_Button);
   ObjectDelete(strG_AddSmartLines_Button);
   ObjectDelete(strG_DelSmartLines_Button);
   
   //ObjectDelete(strG_BTC_TTF_Label);
   //ObjectDelete(strG_BTC_HTF_Label);
   
   ObjectDelete(strG_BTC_p1_Label);
   ObjectDelete(strG_BTC_p2_Label);   
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
   //zakresy obliczeń
   int intL_BTC      = rates_total-prev_calculated+1;
   int intL_BTC_HTF  = intL_BTC;
   //początek obliczeń
   if       (prev_calculated==0)          //dla pierwszego przelotu
   {
      intL_BTC       = intL_BTC=Bars-intE_RSI_VAL-1;
      intL_BTC_HTF   = intL_BTC; 
   }
   else if  (prev_calculated==rates_total)//przelicza tylko ostatni
   {
      intL_BTC       = 0;
      intL_BTC_HTF   = 0;
   }
   else
   {

      if  (enmG_TF_1st!=enmG_TF_2nd)
      if  (iBarShift(NULL,enmG_TF_2nd,Time[0]) != iBarShift(NULL,enmG_TF_2nd,Time[1]))
      {
         intL_BTC_HTF = 2*intG_BarsBackToCalc+1;
      }  
   }  

   //oblicza RSI dla MEDIANY ceny
   for(int i=0;i<=intL_BTC;i++) arr_RSI[i]=iRSI(NULL,0,intE_RSI_VAL,enmE_MetodaCeny,i);
   
   if(blnE_Czy_HTF)
   for(int i=0;i<=intL_BTC_HTF;i++) 
   {
      int intL_HTF = iBarShift(NULL,enmG_TF_2nd,Time[i]);
      arr_RSI_HTF[i]= iRSI(NULL,enmG_TF_2nd,intE_RSI_HTF,enmE_MetodaCeny,intL_HTF);
   }

   //oblicza fraktale
   if       (prev_calculated == 0)           calc_Fractals(0);
   else                                      calc_Fractals(1);
   
   //oblicza major fractale
   if       (prev_calculated == 0)           calc_Fractals_Major(0);
   else if  (prev_calculated!=rates_total)   calc_Fractals_Major(1);

   //oblicza przedłużenia
   if       (prev_calculated == 0)           calc_Fractals_Ext(0);
   else if  (prev_calculated!=rates_total)   calc_Fractals_Ext(1);



   //--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Trzy rodzaje fraktali - rozwiązanie poniżej                      |
//+------------------------------------------------------------------+
void calc_Fractals(int head_mode)
{
   int n=0;
   if       (head_mode == 0) n = Bars-intE_RSI_VAL-1;
   else if  (head_mode == 1)
   {
      for(int i=0;i<Bars;i++)
      {
         if(arr_Fr_Dn[i]>0 || arr_Fr_Up[i]>0)
         {
            n = i;
            break;
            
         }   
      }
   }
   
   ///
   for(int i=2;i<=n;i++)//dla eksperymentu zmiana z 3 na 2 
   {      
      arr_Fr_Up[i] = 0; arr_Fr_Dn[i] = 0;
      if(arr_RSI[i]>=arr_RSI[i+1] && arr_RSI[i]>=arr_RSI[i+2])
      if(arr_RSI[i]>=arr_RSI[i-1] && arr_RSI[i]>=arr_RSI[i-2])
      {
         arr_Fr_Up[i] = arr_RSI[i];
      }
      
      if(arr_RSI[i]<=arr_RSI[i+1] && arr_RSI[i]<=arr_RSI[i+2])
      if(arr_RSI[i]<=arr_RSI[i-1] && arr_RSI[i]<=arr_RSI[i-2])
      {
         arr_Fr_Dn[i] = arr_RSI[i];
      }
   }
}
//+------------------------------------------------------------------+
void calc_Fractals_Major(int head_mode)
{
   int n=0;
   if       (head_mode == 0) n = Bars-intE_RSI_VAL-1;
   else if  (head_mode == 1)
   {
      for(int i=0;i<Bars;i++)
      {
         if(arr_Fr_Dn_Major[i]>0 || arr_Fr_Up_Major[i]>0)
         {
            n = i;
            break;
         }   
      }
   }

   ///
   for(int i=3;i<n;i++)
   {      
      arr_Fr_Up_Major[i] = 0;
      if(arr_Fr_Up[i]>=50)
      for(int j=i-1;j>2;j--)
      {
         if(arr_Fr_Up[j]>0)
         {
            if(arr_Fr_Up[j]<arr_Fr_Up[i])
            {
               for(int k=i+1;k<Bars;k++)
               {
                  if(arr_Fr_Up[k]>0)
                  {
                     if    (arr_Fr_Up[k]<arr_Fr_Up[i]) arr_Fr_Up_Major[i] = arr_Fr_Up[i];
                     else  break;
                  }    
               }
            }
            else break;
         }
      }
   }
   ///
   for(int i=3;i<n;i++)
   {      
      arr_Fr_Dn_Major[i] = 0;
      if(arr_Fr_Dn[i]>0 && arr_Fr_Dn[i]<=50)
      for(int j=i-1;j>2;j--)
      {
         if(arr_Fr_Dn[j]>0)
         {
            if(arr_Fr_Dn[j]>arr_Fr_Dn[i])
            {
               for(int k=i+1;k<Bars;k++)
               {
                  if(arr_Fr_Dn[k]>0)
                  {
                     if    (arr_Fr_Dn[k]>arr_Fr_Dn[i]) arr_Fr_Dn_Major[i] = arr_Fr_Dn[i];
                     else  break;
                  }    
               }
            }
            else break;
         }
      }
   }
}
//+------------------------------------------------------------------+
void calc_Fractals_Ext(int head_mode) //___
{
   int n=0;
   if       (head_mode == 0) n = Bars-intE_RSI_VAL-1;
   else if  (head_mode == 1)
   {
      for(int i=0;i<Bars;i++)
      {
         if(arr_Fr_Dn[i]>0 || arr_Fr_Up[i]>0)
         {
            n = i;
            break;
         }   
      }
   }
   ///
   for(int i=3;i<n;i++)
   {
      if(arr_Fr_Up[i]>0)
      {
         for(int j=i-1;j>=i-intG_Dots_Reach;j--)
         {
            if(j<0) break;
            if(arr_Fr_Up[j]>0) break; // nie nachodzi na kolejny
            arr_Fr_Up___[j] = arr_Fr_Up[i];
         }
     }
      if(arr_Fr_Dn[i]>0)
      {
         for(int j=i-1;j>=i-intG_Dots_Reach;j--)
         {
            if(j<0) break;
            if(arr_Fr_Dn[j]>0) break; // nie nachodzi na kolejny
            arr_Fr_Dn___[j] = arr_Fr_Dn[i];
         }
     }
   }
}
//+------------------------------------------------------------------+ 
//| MouseState                                                       | 
//+------------------------------------------------------------------+ 
string MouseState(uint state) 
  { 
   string res; 
   res+="\nML: "   +(((state& 1)== 1)?"DN":"UP");   // mouse left 
   res+="\nMR: "   +(((state& 2)== 2)?"DN":"UP");   // mouse right  
   res+="\nMM: "   +(((state&16)==16)?"DN":"UP");   // mouse middle 
   res+="\nMX: "   +(((state&32)==32)?"DN":"UP");   // mouse first X key 
   res+="\nMY: "   +(((state&64)==64)?"DN":"UP");   // mouse second X key 
   res+="\nSHIFT: "+(((state& 4)== 4)?"DN":"UP");   // shift key 
   res+="\nCTRL: " +(((state& 8)== 8)?"DN":"UP");   // control key 
   return(res); 
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   bool blnL_Button_STL_State = ObjectGetInteger(ChartID(),strG_AddSmartLines_Button,OBJPROP_STATE);



   if(id==CHARTEVENT_MOUSE_MOVE)
   {
      //--- Prepare variables 
      int      x     =(int)lparam; 
      int      y     =(int)dparam; 
      datetime dt    =0; 
      double   price =0; 
      int      window=0; 
      
      if(blnL_Button_STL_State)
      {
            datetime dtmL_t=0;            
            int      intL_i=0;
            double   dblL_r=0;
            ObjectSetInteger(0,strG_BTC_p1_Label,OBJPROP_XDISTANCE,10);
            ObjectSetInteger(0,strG_BTC_p2_Label,OBJPROP_XDISTANCE,10);
         
         
         
         if(ChartXYToTimePrice(0,x,y,window,dt,price))
         {
            dtmL_t = dt;            
            intL_i = iBarShift(NULL,0,dt);
            dblL_r = arr_RSI[intL_i];
         }
         if(window == WindowFind(strG_NazwaIndi))
         {
            if(dblG_p_1==0)
            {
               ObjectSetString(0,strG_BTC_p1_Label,OBJPROP_TEXT,"P1 search>> RSI: "+DoubleToStr(dblL_r,1)+" @Bar: "+IntegerToString(intL_i));
               ObjectSetInteger(0,strG_BTC_p1_Label,OBJPROP_XDISTANCE,x);
               //ObjectSetInteger(0,strG_BTC_p1_Label,OBJPROP_YDISTANCE,y);
            }
            else if(dblG_p_2==0)
            {
               if(ObjectFind("T-Line_1")<0)
               {
                  //Alert(dblG_p_1,";",dblG_p_2,";",ObjectFind("T-Line_1"));
                  
                  draw_Smart_Line(window,dtmL_t,1,dtmL_t,1);
                  zeruj_wyniki();
               }
               else
               {
                  ObjectSetString(0,strG_BTC_p2_Label,OBJPROP_TEXT,"P2 serach>> RSI: "+DoubleToStr(dblL_r,1)+" @Bar: "+IntegerToString(intL_i));
                  ObjectSetInteger(0,strG_BTC_p2_Label,OBJPROP_XDISTANCE,x);
               }   
            }
         }
      }
     
      //Comment("POINT: ",(int)lparam,",",(int)dparam,"\n",MouseState((uint)sparam)); 
   
   }
   
   //dodawanie smart lines
   if(blnL_Button_STL_State)
   {
      if(id==CHARTEVENT_CLICK)
      {

         //--- Prepare variables 
         int      x     =(int)lparam; 
         int      y     =(int)dparam; 
         datetime dt    =0; 
         double   price =0; 
         int      window=0; 
   
         //--- Converts the X and Y coordinates in terms of date/time 
         if(ChartXYToTimePrice(0,x,y,window,dt,price))
         { 
            if(dblG_p_1==0)
            {
               dblG_p_1 = price;
               dtmG_t_1 = dt;            
               intG_i_1 = iBarShift(NULL,0,dt);
               dblG_r_1 = arr_RSI[intG_i_1];
               ObjectSetString(0,strG_BTC_p1_Label,OBJPROP_TEXT,"P1: RSI: "+DoubleToStr(dblG_r_1,1)+" @Bar: "+IntegerToString(intG_i_1));
            }             
            else if (dblG_p_2 == 0)
            {
             
               dblG_p_2 = price;
               dtmG_t_2 = dt;            
               intG_i_2 = iBarShift(NULL,0,dt);
               dblG_r_2 = arr_RSI[intG_i_2];
               ObjectSetString(0,strG_BTC_p2_Label,OBJPROP_TEXT,"P2: RSI: "+DoubleToStr(dblG_r_2,1)+" @Bar: "+IntegerToString(intG_i_2));
            }
   
            if(dblG_p_2>0)
            {  
               draw_Smart_Line(window,dtmG_t_1,dblG_r_1,dtmG_t_2,dblG_r_2);
               zeruj_wyniki();
            }
         }
      }
   }
   else
   {
      ObjectSetString(0,strG_BTC_p1_Label,OBJPROP_TEXT," ");
      ObjectSetString(0,strG_BTC_p2_Label,OBJPROP_TEXT," ");
   }
   // kasowanie smart lines
   if(sparam==strG_DelSmartLines_Button)
   {
      //skoro kasujemy to dezaktywuje ew. włączony guzik do trworzenia linii
      ObjectSetInteger(ChartID(),strG_AddSmartLines_Button,OBJPROP_STATE,false);
      ////zerowanie wyników
      dblG_p_1 = 0; dtmG_t_1 = 0; intG_i_1 = 0; dblG_r_1 = 0;
      dblG_p_2 = 0; dtmG_t_2 = 0; intG_i_2 = 0; dblG_r_2 = 0;
      //
      bool blnL_Button_DSL_State = ObjectGetInteger(ChartID(),strG_DelSmartLines_Button,OBJPROP_STATE);
      //
      if(blnL_Button_DSL_State)
      {
         delete_SmartLines();
         ObjectSetInteger(ChartID(),strG_DelSmartLines_Button,OBJPROP_STATE,false);
      }
      else
      {
         ObjectSetInteger(ChartID(),strG_DelSmartLines_Button,OBJPROP_STATE,false);
      }
   }
   //poczatek auto linii
   if( id == CHARTEVENT_OBJECT_CLICK )
   {
      if(sparam==strG_AddSmartLines_Button)
      {
         bool blnL_Button_ASM_State = ObjectGetInteger(ChartID(),strG_DelSmartLines_Button,OBJPROP_STATE);
         
         ObjectDelete(0,"T-Line_1");
                  
         
         if(blnL_Button_ASM_State == false)
         {
            //deaktywnowanie linii
            for(int i=0;i<ObjectsTotal();i++)
            {
               if(StringSubstr(ObjectName(i),0,6) == "T-Line") 
                  ObjectSetInteger(0,ObjectName(i),OBJPROP_SELECTED,false); 
            }
         }
      }
      if(sparam==strG_TLB_Button)
      {
      //bold line
         bool blnL_Button_TLB_State = ObjectGetInteger(ChartID(),strG_TLB_Button,OBJPROP_STATE);
              
         if(blnL_Button_TLB_State)
         {
            add_T_Line();
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
      //bold line
         bool blnL_Button_TLD_State = ObjectGetInteger(ChartID(),strG_TLD_Button,OBJPROP_STATE);
              
         if(blnL_Button_TLD_State)
         {
            delete_All_RSI_T_Lines();
            ObjectSetInteger(ChartID(),strG_TLD_Button,OBJPROP_STATE,false);
         }
         else
         {
            ObjectSetInteger(ChartID(),strG_TLD_Button,OBJPROP_STATE,false);
         }
      }
   }       
}
//+------------------------------------------------------------------+
void zeruj_wyniki()
{
   //zerowanie wyników
   dblG_p_1 = 0; dtmG_t_1 = 0; intG_i_1 = 0; dblG_r_1 = 0;
   dblG_p_2 = 0; dtmG_t_2 = 0; intG_i_2 = 0; dblG_r_2 = 0;
   ObjectSetString(0,strG_BTC_p1_Label,OBJPROP_TEXT,"P1: RSI: "+DoubleToStr(dblG_r_1,1)+" @Bar: "+IntegerToString(intG_i_1));
   ObjectSetString(0,strG_BTC_p2_Label,OBJPROP_TEXT,"P2: RSI: "+DoubleToStr(dblG_r_2,1)+" @Bar: "+IntegerToString(intG_i_2));
   
}
//+------------------------------------------------------------------+
void draw_Smart_Line(int head_window, datetime head_t1, double head_rsi_1, datetime head_t2, double head_rsi_2)
{
   string strL_LineName;
   bool blnL_NewLineFound = false;
   int n=0;
   
   while(!blnL_NewLineFound && n<=2147483647)
   {
      n++;
      blnL_NewLineFound = true;

      strL_LineName =  "T-Line_"+IntegerToString(n);
      
      for(int j=0;j<=ObjectsTotal();j++)
      {
         if(ObjectName(j) == strL_LineName)
         {
            blnL_NewLineFound = false;
            break;
         }
      }
   }
   create_Trend(head_window,strL_LineName,head_t1,head_rsi_1,head_t2,head_rsi_2,clrGold,STYLE_SOLID,2,true);
}
//+------------------------------------------------------------------+
bool add_T_Line(  const ENUM_LINE_STYLE head_style =  STYLE_SOLID,
                  const long            head_thick =  1)
{
   string strL_Line_Name = "AmazinG TL ";
   
   //oblicza dwie ostatnie wartości fraktali up i na tej bazie rysuje linie trendu
   intG_WinIdx=WindowFind(strG_NazwaIndi);
   int k=0;
   int t1 = 0, t2 = 0;
   double p1 = -1, p2 = -1;
   
   for(int i=k;i<Bars;i++)
   {
      if(arr_Fr_Up_Major[i]>0)
      {
         t2 = i; p2 = arr_Fr_Up_Major[i];
         for(int j=i-1;i>2;j--)
         {
            if(arr_Fr_Up[j]>0)
            {
               t1 = j;
               p1 = arr_Fr_Up[j];
               
               //rysuje linie trendu
               string strL_X_LineName = StringConcatenate(strL_Line_Name,IntegerToString(t1),".",IntegerToString(t2));
               //ObjectDelete(strL_X_LineName);
               if(create_Trend_t(intG_WinIdx,strL_X_LineName,Time[t2],p2,Time[t1],p1,clrGold))
               {
                  ObjectSetInteger(ChartID(),strL_X_LineName,OBJPROP_RAY_RIGHT,true);
                  ObjectSetInteger(ChartID(),strL_X_LineName,OBJPROP_SELECTABLE,true); 
                  ObjectSetInteger(ChartID(),strL_X_LineName,OBJPROP_SELECTED,true);
                  ObjectSetInteger(ChartID(),strL_X_LineName,OBJPROP_HIDDEN,false);
                  ObjectSetInteger(ChartID(),strL_X_LineName,OBJPROP_WIDTH,head_thick);
                  ObjectSetInteger(ChartID(),strL_X_LineName,OBJPROP_STYLE,head_style);
               }
            }
         }
         if (i>233)break;
      }
   }

   return false;
}
//+------------------------------------------------------------------+
void delete_All_RSI_T_Lines()
{
   //for(int i=0;i<ObjectsTotal();i++)
   //{
   ObjectsDeleteAll(ChartID(),intG_WinIdx,OBJ_TREND);
   //  }
   //ObjectFind(
   //ObjectsTotal
}

void find_Last_Up_Fractal()
//20200329
{
   int k=0;
   int t1 = 0, t2 = 0;
   double p1 = -1, p2 = -1;
   
   for(int i=k;i<Bars;i++)
   {
      if(arr_Fr_Up[i]>0)
      {
         t1 = i; p1 = arr_Fr_Up[i];
         for(int j=i+1;i<Bars;j++)
         {
            if(arr_Fr_Up[j]>0)
            {
               t2 = j;
               p2 = arr_Fr_Up[j];
               break;
            }
         }
      }
      if (t2>0) break;
   }
}
//+------------------------------------------------------------------+
void delete_SmartLines()
{
   bool blnL_SaSmartLinie=true;
   while(blnL_SaSmartLinie)
   {
      blnL_SaSmartLinie = false;
      for(int i=0;i<ObjectsTotal();i++)
      {
         string strL_ObjName = ObjectName(i);
         if(StringSubstr(strL_ObjName,0,6)=="T-Line")
         {
            ObjectDelete(strL_ObjName);
            blnL_SaSmartLinie = true;
         }
      }
    } 
}
//+------------------------------------------------------------------+ 
//| Create a trend line by the given coordinates                     | 
//+------------------------------------------------------------------+ 
bool create_Trend_t(
                 const int             sub_window=0,      // subwindow index                  
                 const string          name="TrendLine",  // line name 
                 datetime              time1=0,           // first point time 
                 double                price1=0,          // first point price 
                 datetime              time2=0,           // second point time 
                 double                price2=0,          // second point price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            ray_right=false,   // line's continuation to the right 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0,
                 const long            chart_ID=0)       // chart's ID 
{ 
 if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a trend line! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
}

//+------------------------------------------------------------------+
bool add_T_Line_Base(  const ENUM_LINE_STYLE head_style =  STYLE_SOLID,
                  const int             head_thick =  1)
{
   string strL_Line_Name = "AmazinG TL ";
   
   intG_WinIdx=WindowFind(strG_NazwaIndi);
   for(int i=0;i<999;i++)
   {
      string strL_X_LineName = StringConcatenate(strL_Line_Name,IntegerToString(i));
      if(ObjectFind(ChartID(),strL_X_LineName)<0)
      if(create_Trend_t(intG_WinIdx,strL_X_LineName,Time[20],55,Time[0],60,clrGold,STYLE_SOLID,head_thick,true,true,false,false))
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
//+------------------------------------------------------------------+
bool check_crosses_against_trend_line()
{
   for(int i=0;i<21;i++)
   {
      double dblL_LineVal = ObjectGetValueByShift("T-Line",i);
      Alert("i=",i," val=",dblL_LineVal);
      if(arr_RSI[i]<=dblL_LineVal  && arr_RSI[i+1] >= dblL_LineVal)
      {
         Alert("Spadek poniżej linii trendu RSI",i);
         //return true;
      }
      
      if(arr_RSI[i]>=dblL_LineVal  && arr_RSI[i+1] <= dblL_LineVal)
      {
         Alert("Wzrost powyżej linii trendu RSI",i);
         //return true;
      }
   }
   return false;
}