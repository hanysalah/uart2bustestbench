#include <iostream>

using namespace std;

int gcd_calc (int x, int y);

int main()
{
    unsigned int gcd_result;
    unsigned int buad_rate,buad_freq,global_clock;
    cout << "enter buad rate" << endl;
    cin >> buad_rate ;
    cout << "enter global clock" << endl;
    cin >> global_clock ;
    gcd_result = gcd_calc(global_clock,(16*buad_rate));
    buad_freq = (16*buad_rate)/gcd_result;
    cout << "buad_freq = "  << buad_freq << endl;

    return 0;
}

int gcd_calc(int x, int y)
{
    int result =1;
    bool break_loop = false;
    int div;
    div =2;
    while (break_loop == false)
    {
        if ((x%div == 0) && (y%div ==0))
        {
        result = result*div;
        x=x/div;
        y=y/div;
        }
        else
        {
        div++;
        }
        if((div > x)|| (div > y))
        {
            break_loop = true;
        }
    }
    return result;
}

