//+------------------------------------------------------------------+
//|                                  alfa Simons ZigZag 20171012.mq4 |
//|                                            (c) Szymon Marek 2017 |
//|                                       http://www.SzymonMarek.com |
//+------------------------------------------------------------------+
#property copyright "(c) Szymon Marek 2017-2018"
#property link      "http://www.SzymonMarek.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property description "Simon's Swing Finder"
#property description " "
#property description "Zaznacza swingi o predefiniowanym parametrze. Dla mniejszych TF (Max M30) wyświetla tabelę swingów z osatniego dnia."
//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
#property indicator_color1 clrLavender
#property indicator_width1 2
#property indicator_style1 STYLE_SOLID
//+------
#property indicator_color2 clrLime
#property indicator_width2 1
//+------
#property indicator_color3 clrRed
#property indicator_width3 1
//+------------------------------------------------------------------+
#property indicator_buffers 3
double arr_HL[], arr_H[], arr_L[];
//+------------------------------------------------------------------+
enum ENUMS_HorL
{
   hol_No,
   hol_High,
   hol_Low
};
//+------------------------------------------------------------------+
enum ENUMS_DOT_TYPE
{
   dot_Bigger        = 159,
   dot_Diamond       = 116,
   dot_Circle        = 161,
   dot_Square        = 168
};
//+------------------------------------------------------------------+
//| globalne zmienne
//+------------------------------------------------------------------+
string   strG_NazwaIndi;
long     lngG_ID        = ChartID();   //chart ID
//nazwa Buttona
string strG_SW = "sSwing";
string strG_Shade_Table_1="Swing Shade";
string strG_Shade_Table_2="Swing Shade_2";
int intG_BTC, intG_Bars;
int intG_n_print;
//+------------------------------------------------------------------+
//globalne zewnętrzne
//+------------------------------------------------------------------+
extern string           s0 = "--- Widoczność Oscylatora na Wykresie ---";              //---
extern bool             blnE_Czy_Widoczny    = true;                                   //czy widoczny
extern string           s1 = "--- Czy Wyświetlać Statystyki Ost Swingu ---";           //---
extern bool             blnE_Czy_Info        = false;
extern string           s2 = "--- Czy Wyświetlać Statystyki Swingów na Wykresie ---";  //---
extern bool             blnE_Czy_Tabela      = false;
extern int              intE_IleSwingow      = 18;                                     //ile maxymalnie swingow wyswietla
extern string           s3 = "+--- Ustawienia Zasięgu Swingów ---+";                   //---
extern int              intE_Zakres          = 6;
extern ENUMS_DOT_TYPE   enmE_DotType         = dot_Bigger; 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //---+ indicator buffers mapping
   SetIndexBuffer(0,arr_HL);  SetIndexLabel(0,"_");                                    SetIndexEmptyValue(0,0.0);
   SetIndexBuffer(1,arr_H);   SetIndexArrow(1,enmE_DotType);   SetIndexLabel(1,"H");   SetIndexEmptyValue(1,0.0);
   SetIndexBuffer(2,arr_L);   SetIndexArrow(2,enmE_DotType);   SetIndexLabel(2,"L");   SetIndexEmptyValue(2,0.0);
   //
   show_ButtonsOnScreen(strG_SW,"S",intU_X+intU_Btn_width*2,intU_Y+intU_Btn_hight*1,intU_Btn_width,intU_Btn_hight);

   //wyświetlanie Swingów na wykresie
   if(blnE_Czy_Widoczny)
   {
      bool blnL_Button_ZZ_State = ObjectGetInteger(lngG_ID,strG_SW,OBJPROP_STATE);
      if(!blnL_Button_ZZ_State)
      show_ZZ_On();
   }
   else
   {
      show_ZZ_Off();
      change_Button_State_Off(strG_SW);//guzik tez
   }
   //
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void show_ZZ_On()
{
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexStyle(2,DRAW_ARROW);
}
//+------------------------------------------------------------------+
void show_ZZ_Off()
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
   ObjectDelete(ChartID(),strG_SW);
   delete_swing_info();
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
   //---
   intG_BTC = rates_total;
   
   double dblL_L, dblL_H;
   int intL_i;
   
   if(intG_BTC!=intG_BTC) intL_i=intG_BTC; else intL_i = 0;
   
   bool blnL_DoIt = false;
   
   //20180706 dodatek uaktualniający ost słupek
   for(int i=0;i<intG_BTC;i++)
   {
      if(arr_HL[i]!=0)
      {
         if       (arr_H[i]>0)
         {
            dblL_H = arr_H[i];
            if (High[iHighest(NULL,0,MODE_HIGH,intE_Zakres,0)]>arr_H[i]) blnL_DoIt = true;
            
         }
         else if  (arr_L[i]>0)
         {
            dblL_L = arr_L[i];
            if (Low[iLowest(NULL,0,MODE_LOW,intE_Zakres,0)]<arr_L[i]) blnL_DoIt = true;
         }
         break;
      }
   }

   // 
   if(rates_total!= prev_calculated || blnL_DoIt) //blnL_DoIt jako true aktualizuje ost słupek
   {
      int n = 0;
      for(int i=0;i<rates_total;i++)
      {
         if(arr_HL[i]!=0) n++;
         if(n>=3)
         {
            intG_BTC = i+1;
            
            // zeruje wcześniejsze znalezienia
            for(int j=0;j<intG_BTC;j++)
            {
               arr_HL[j] = 0;
               arr_H[j]  = 0;
               arr_L[j]  = 0;
            }
            
            break; 
         }
      }
      Show_HighsLows_Idx(intG_BTC);
      
      if(rates_total!= prev_calculated || blnL_DoIt) //blnL_DoIt jako true aktualizuje ost słupek
      {      
         //wyświetla dane w postaci tabeli
         if(blnE_Czy_Tabela)
         {
            //if(Period()>=PERIOD_M1 && Period()<PERIOD_H1)
            {
               delete_swing_info();
               print_swing_info();
            }
            //else
            //   delete_swing_info();
         }
         //na pasku komentarz o osttanim swingu
         if(blnE_Czy_Info)
         {
            //
            show_Comment();
         }
      }
   }
   
   
   //--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
void Show_HighsLows_Idx(const int total)
{
// ta magiczna formuła znajduje punkty zwrotne i rysuje zygzaka na ekranie
   
   ENUMS_HorL  holL_Prev_HL=hol_No; //rodzaj poprzedniego, wobec obecnego, wierzchołka
   int         intL_Prev_Idx = -1;  //indeks poprzedniego, wobec obecnego, wierzchołka
   
   //szukam kandydata
   for(int i=0;i<total;i++)
   {
      int intL_Prawy = i-(intE_Zakres-1);
      if(intL_Prawy<0) intL_Prawy = 0;
   
      if (i == iHighest(NULL,0,MODE_HIGH,intE_Zakres,i) && i==iHighest(NULL,0,MODE_HIGH,intE_Zakres,intL_Prawy))
      {
         //najpierw mówi że znalazł okeja
         arr_H[i] = High[i];
         
         //dla pierwszego przelotu         
         if(intL_Prev_Idx<0)
         {
            arr_HL[i] = High[i];
            intL_Prev_Idx = i;
            holL_Prev_HL = hol_High;
         }
         //jeśli wcześniejszy przelot też dał szczyt
         else if (holL_Prev_HL == hol_High)
         {
            //ale słabszy
            if(High[i]>arr_HL[intL_Prev_Idx])
            {
               arr_HL[i] = High[i];       //dodaje nowe znalezienie
               arr_HL[intL_Prev_Idx]=0;   //zeruje poprzednie znalezienie
               intL_Prev_Idx = i;
            }
            else
            //a co jeśli mocniejszy???
            {
               //to tego znalezienia nie zapisuje zatem nic tu nie trzeba robić
            }
         }
         //jeśli poprzedni przelot nie dał szczytu, tylko dołek wówczas zapisuję to znalezienie
         else
         {
            arr_HL[i] = High[i];          //dodaje nowe znalezienie               
            intL_Prev_Idx = i;
            holL_Prev_HL = hol_High;
         }
      }
      else if  (i==iLowest(NULL,0,MODE_LOW,intE_Zakres,i) && i==iLowest(NULL,0,MODE_LOW,intE_Zakres,intL_Prawy))
      {

         //najpierw mówi że znalazł okeja
         arr_L[i] = Low[i];

         //dla pierwszego przelotu         
         if(intL_Prev_Idx<0)
         {
            arr_HL[i] = Low[i];
            intL_Prev_Idx = i;
            holL_Prev_HL = hol_Low;
         }
         //jeśli wcześniejszy przelot też dał dołek
         else if (holL_Prev_HL == hol_Low)
         {
            //jeśli wcześniejszy przelot też dał dołek, ale słabszy
            if(Low[i]<arr_HL[intL_Prev_Idx])
            {
               arr_HL[intL_Prev_Idx]=0;   //zeruje poprzednie znalezienie
               arr_HL[i] = Low[i];        //dodaje nowe znalezienie
               intL_Prev_Idx = i;
            }
         }
         else
         {
            arr_HL[i] = Low[i];           //dodaje nowe znalezienie
            intL_Prev_Idx = i;
            holL_Prev_HL = hol_Low;
         }
      }
   }
   
   //--koniec
}
//+------------------------------------------------------------------+
void show_Comment()
{
   int intL_HL_0 = -1, intL_HL_1 = -1;
   //znajdowanie dwóch ostatnich punktów swingowych
   for(int i=0;i<Bars;i++)
   {
      if(arr_HL[i]!=0)
      {
         if       (intL_HL_0 > -1 && intL_HL_1 == -1) {intL_HL_1 = i;break;}
         else if  (intL_HL_0 == -1)                   {intL_HL_0 = i;} 
      }
   }
   
   //obliczanie różnicy   
   string strL_ActDif = DoubleToStr(arr_HL[intL_HL_0] - arr_HL[intL_HL_1],Digits());
   
   string strL_Time_HL_0 = calc_TimeForLastSwing(intL_HL_0);
   string strL_Time_HL_1 = calc_TimeForLastSwing(intL_HL_1);
   
   //przygotowanie treści do wyświetlenia                  
   if       (arr_H[intL_HL_1]!=0)   strL_ActDif = "(" + strL_Time_HL_0 + ") Act Low["   + IntegerToString(intL_HL_0) + "] v. (" + strL_Time_HL_1+ ") High["+IntegerToString(intL_HL_1)+"] || Dist. = "+ strL_ActDif;
   else if  (arr_L[intL_HL_1]!=0)   strL_ActDif = "(" + strL_Time_HL_0 + ") Act High["  + IntegerToString(intL_HL_0) + "] v. (" + strL_Time_HL_1+ ") Low["+IntegerToString(intL_HL_1)+"] || Dist. = " + strL_ActDif;
   
   int intL_TimeDist = intL_HL_1 - intL_HL_0;
   double dblL_AvSpeed = (arr_HL[intL_HL_0] - arr_HL[intL_HL_1])/intL_TimeDist;
   string strL_Av_Speed = DoubleToStr(dblL_AvSpeed,Digits());
   strL_ActDif = strL_ActDif + "p || in = " + IntegerToString(intL_HL_1 - intL_HL_0) + " Bars at avr.Speed = " + strL_Av_Speed ;
   
   Comment(strL_ActDif); 
}
//+------------------------------------------------------------------+
string calc_TimeForLastSwing(int head_i)
{
   //obliczanie czasu
   string strL_Time_HL;
   if       (Period()>=PERIOD_D1)                  strL_Time_HL = TimeToStr(Time[head_i],TIME_DATE);
   else
   {
      if(TimeDay(Time[head_i])!=TimeDay(Time[0]))  strL_Time_HL = TimeToStr(Time[head_i],TIME_DATE|TIME_MINUTES);
      else                                         strL_Time_HL = TimeToStr(Time[head_i],TIME_MINUTES);
   }
   
   return strL_Time_HL;
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---
   if( id == CHARTEVENT_OBJECT_CLICK )
   {
      //ukryvanie geom 22/06/2018
      if(sparam==strG_SW)
      {
         
         bool blnL_Button_ZZ_State = ObjectGetInteger(lngG_ID,strG_SW,OBJPROP_STATE);
         if(!blnL_Button_ZZ_State)
         {
            show_ZZ_On();
            change_Button_State_On(strG_SW);
         }
         else
         {
            show_ZZ_Off();
            change_Button_State_Off(strG_SW);
         }
      }
   }
}
//+------------------------------------------------------------------+
void print_swing_info()
{
   int n=-1;
   double   col_Swing_Val[100];
   int      col_Swing_HL[100];
   int      col_Swing_i[100];
   double   col_Swing_PriceChange[100];

   double dblL_LL_suma = 0;   int intL_LL_n = 0;   double dblL_LL_avr;
   double dblL_HH_suma = 0;   int intL_HH_n = 0;   double dblL_HH_avr;
 
   //pierwszy przelot i zapisanie kolekcji
   for(int i=0;i<Bars;i++)
   {
      //if(TimeDay(Time[i]) >= Day())
      if(n<50)
      {
         if(arr_HL[i]!=0)
         {
            n++;
                                    col_Swing_Val[n]  = arr_HL[i];   //przechowuje wartość
            if(arr_H[i]!=0)         col_Swing_HL[n]   = 1;           //przechowuje high or low
            else if (arr_L[i]!=0)   col_Swing_HL[n]   = -1;   
                                    col_Swing_i[n]    = i;           //przechowuje numer bara
            
         }
      }
      else break;
   }

   //drugi przelot: przypisanie zmian ceny i obliczenie średnich
   for(int i=0;i<n;i++)
   {
      col_Swing_PriceChange[i] = col_Swing_Val[i] - col_Swing_Val[i+1];
      
      if(col_Swing_HL[i] == -1) {dblL_LL_suma = dblL_LL_suma + col_Swing_PriceChange[i];intL_LL_n++;}//  Alert("intL_LL_n=",intL_LL_n," LL suma: ", dblL_LL_suma);}
      if(col_Swing_HL[i] == 1)  {dblL_HH_suma = dblL_HH_suma + col_Swing_PriceChange[i];intL_HH_n++;}//  Alert("intL_HH_n=",intL_HH_n," HH suma: ", dblL_HH_suma);}
   }
   if(intL_HH_n>0) dblL_HH_avr = dblL_HH_suma/intL_HH_n; string strL_HH_avr = "AvUp " + convert_result(dblL_HH_avr);//DoubleToStr(dblL_HH_avr,Digits());
   if(intL_LL_n>0) dblL_LL_avr = dblL_LL_suma/intL_LL_n; string strL_LL_avr = "AvDn " + convert_result(dblL_LL_avr);//DoubleToStr(dblL_LL_avr,Digits());
   
   //trzeci przelot i printout wyniku z kolorowaniem
   int m;
   //Alert(n);
   if (intE_IleSwingow>n) m=n;else m=intE_IleSwingow;
 
   color clrL_Shade = ChartGetInteger(lngG_ID,CHART_COLOR_BACKGROUND);  
   int intL_X_b = 60;//było 15
   int intL_Y_b = 56;//26;//bylo 37


   int intL_Width, intL_X_lp, intL_X_hl, intL_X_time, intL_X_bars, intL_pc;
   if(Period()<PERIOD_H1)
   {
      intL_X_lp   = intL_X_b + 5;
      intL_X_hl   = intL_X_b + 35;
      intL_X_time = intL_X_b + 55;
      intL_X_bars = intL_X_b + 105;
      intL_pc     = intL_X_b + 140;
      intL_Width  = 180;      
   }
   else if (Period()<PERIOD_D1)
   {
      intL_X_lp   = intL_X_b + 5;
      intL_X_hl   = intL_X_b + 35;
      intL_X_time = intL_X_b + 55;
      intL_X_bars = intL_X_b + 170;
      intL_pc     = intL_X_b + 195;
      intL_Width = 240;      
   }
   else
   {
      intL_X_lp   = intL_X_b + 5;
      intL_X_hl   = intL_X_b + 35;
      intL_X_time = intL_X_b + 55;
      intL_X_bars = intL_X_b + 130;
      intL_pc     = intL_X_b + 155;
      intL_Width  = 210;
   }

   create_Button  (lngG_ID,strG_Shade_Table_1, 0,intL_X_b,     intL_Y_b+22,intL_Width,(m+2)*16,CORNER_LEFT_UPPER,"","Arial",8,  clrL_Shade,clrL_Shade,clrL_Shade); //cien
   create_Button  (lngG_ID,strG_Shade_Table_2, 0,intL_X_b+90,  intL_Y_b,90,22,CORNER_LEFT_UPPER,"","Arial",8,  clrL_Shade,clrL_Shade,clrL_Shade); //cien
   //oddzielnie haje odzielnie lowy
   intG_n_print = 0;
   int intL_Y = 0, intL_Y_HH = 0, intL_Y_LL = 0;


   
   double dblL_RealReminder = MathMod(n,2);//Alert(dblL_RealReminder);
   int intL_LL_Base;
   if (dblL_RealReminder > 0) intL_LL_Base = intL_Y_b + 20 + (m/2+2)*16;else intL_LL_Base =intL_Y_b + 20 + (m/2+1)*16;
   
   string strL_Font_Bold = "Calibri";
   int    intL_Font_B_Size = 11;
   create_Label(ChartID(),"Swing"+IntegerToString(099),0,intL_X_b+90, intL_Y_b+20, CORNER_LEFT_UPPER, strL_HH_avr,strL_Font_Bold,intL_Font_B_Size,clrLime);
   create_Label(ChartID(),"Swing"+IntegerToString(199),0,intL_X_b+90, intL_LL_Base,CORNER_LEFT_UPPER, strL_LL_avr,strL_Font_Bold,intL_Font_B_Size,clrRed);
   
   for(int i=0;i<m;i++)
   {

      string strL_Time_End;;
      if(Period()<PERIOD_H1)
      {
         strL_Time_End = TimeToStr (Time[col_Swing_i[i]],TIME_MINUTES);
      }
      else if (Period()<PERIOD_D1)
      {
         strL_Time_End = TimeToStr (Time[col_Swing_i[i]],TIME_DATE|TIME_MINUTES);
      }
      else
      {
         strL_Time_End = TimeToStr (Time[col_Swing_i[i]],TIME_DATE);
      }
      
      string strL_HL;   if(col_Swing_HL[i] == 1) strL_HL = "H"; else if (col_Swing_HL[i] == -1) strL_HL = "L";
      string strL_Price_Change   = convert_result  (col_Swing_Val[i] - col_Swing_Val[i+1]);
      string strL_Bars           = IntegerToString (col_Swing_i[i+1] - col_Swing_i[i]);
   
      if       (col_Swing_HL[i] == 1)   {intL_Y_HH++;   intL_Y= intL_Y_b+20 + intL_Y_HH*16;}
      else if  (col_Swing_HL[i] == -1)  {intL_Y_LL++;   intL_Y= intL_LL_Base + intL_Y_LL*16;}

      color clrL_OK = clrWhite;
      if       (col_Swing_PriceChange[i]>dblL_HH_avr) clrL_OK = clrGold;
      else if  (col_Swing_PriceChange[i]<dblL_LL_avr) clrL_OK = clrGold;
      
      if(i == 0) clrL_OK = clrAqua;
      
      string strL_Font = "Calibri";
      int    intL_Font_Size = 11;
      create_Label(ChartID(),"Swing"+IntegerToString(i),    0,intL_X_lp,   intL_Y, CORNER_LEFT_UPPER, IntegerToString(i+1),strL_Font,intL_Font_Size,clrL_OK);
      create_Label(ChartID(),"Swing"+IntegerToString(100+i),0,intL_X_hl,   intL_Y, CORNER_LEFT_UPPER, strL_HL,             strL_Font,intL_Font_Size,clrL_OK);
      create_Label(ChartID(),"Swing"+IntegerToString(200+i),0,intL_X_time, intL_Y, CORNER_LEFT_UPPER, strL_Time_End,       strL_Font,intL_Font_Size,clrL_OK);
      create_Label(ChartID(),"Swing"+IntegerToString(300+i),0,intL_X_bars, intL_Y, CORNER_LEFT_UPPER, strL_Bars,           strL_Font,intL_Font_Size,clrL_OK);
      create_Label(ChartID(),"Swing"+IntegerToString(400+i),0,intL_pc,     intL_Y, CORNER_LEFT_UPPER, strL_Price_Change,   strL_Font,intL_Font_Size,clrL_OK);
   }

}
//+------------------------------------------------------------------+
//do wytestowania
string calc_Median_Price(double &col_Double[])
{
   int intL_Point_Med;
   ArraySort(col_Double,WHOLE_ARRAY,0,MODE_DESCEND);
   int intL_Col_Size = ArraySize(col_Double);
   intL_Point_Med = MathRound(intL_Col_Size);
   
   if    (MathMod(intL_Col_Size,2)!=0)
   {
      return convert_result(col_Double[intL_Point_Med]);
   }
   else
   {
      double dblL_1 = col_Double[intL_Point_Med-1];
      double dblL_2 = col_Double[intL_Point_Med];
      
      return convert_result((dblL_1+dblL_2)/2);
   }
}

//+------------------------------------------------------------------+
string convert_result(double head_Val)
{
   double dblL_Val = head_Val * MathPow(10,Digits()-1);
   if(Digits()>2) return DoubleToStr(dblL_Val,1);
   else           return DoubleToStr(head_Val,Digits());
}
//+------------------------------------------------------------------+
bool delete_swing_info()
{
   for(int i=0;i<=500;i++)
   {
      string strL_S_LineName = StringConcatenate("Swing",IntegerToString(i));
      if(ObjectFind(ChartID(),strL_S_LineName)== 0)
         ObjectDelete(lngG_ID,strL_S_LineName);
      //else if(i>12) break;
   }
   
   ObjectDelete(lngG_ID,strG_Shade_Table_1);
   ObjectDelete(lngG_ID,strG_Shade_Table_2);
   

   return true;
}


