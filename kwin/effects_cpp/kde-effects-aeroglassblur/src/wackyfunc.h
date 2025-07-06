#pragma once

void getMaximizedColorization(int alpha, float red, float green, float blue, float &r, float &g, float &b) // r, g, b are the return values
{
	if(alpha <= 26 || alpha > 217)
	{
		r = 0;
		g = 0;
		b = 0;
		return;
	}
	// Not used because the return values are in the range [0, 1] because of GLSL
	/*auto roundNum = [&](double a) -> int {
		double rem = a - (int)a;
		return (int)a + (rem >= 0.95f ? 1 : 0);
	};*/
	double p = (0.746032 * (double)alpha + 0.111104) / 255.0; // Divided by 255 to normalize the value into the [0, 1] range
	r = p*red;
	g = p*green;
	b = p*blue;

}

void getColorBalances(int sliderPosition, int &primaryBalance, int &secondaryBalance, int &blurBalance)
{
	int pB = 0, sB = 0, bB = 0;

	if(sliderPosition == 0)
	{
		pB = 100;
		sB = 0;
		bB = 100;
		primaryBalance = pB;
		secondaryBalance = sB;
		blurBalance = bB;
		printf("%d %d %d\n", pB, sB, bB);
		return;
	}
	// https://github.com/ALTaleX531/dwm_colorization_calculator/blob/main/main.py
	int balance = int((double(sliderPosition) / 255.0 - 0.1) / 0.75 * 100.0 + 10.0);

	if(balance < 50)
	{
		pB = 5;
		bB = 100 - balance;
		sB = (100 - pB) - bB;
	}
	else if(balance >= 50 && balance < 95)
	{
		sB = 95 - balance;
		bB = 50 - ((balance - 50) >> 1);
		pB = 100 - sB - bB;
	}
	else
	{
		sB = 0;
		pB = balance - 25;
		bB = 100 - pB;
	}
	/*

	// Old algorithm
	int x = sliderPosition;
	//primary
	if(x >= 26 && x < 103)
	{
		pB = 5;
	}
	else if(x >= 103 && x < 188)
	{
		pB = roundNum(0.776471*x - 74.9765);
	}
	else if(x == 188) 
	{
		pB = 71;
	}
	else if(x >= 189 && x <= 217)
	{
		pB = roundNum(0.535714*x - 31.25);
	}

	//secondary
	if(x >= 26 && x < 102)
	{
		sB = roundNum(0.526316*x - 8.68421);
	}
	else if(x >= 102 && x < 189)
	{
		sB = roundNum(-0.517241*x + 97.7586);
	}
	else if(x >= 189 && x <= 217)
	{
		sB = 0;
	}

	//blur 
	if(x >= 26 && x < 102)
	{
		bB = roundNum(-0.526316*x + 103.6842);
	}
	else if(x >= 102 && x < 188)
	{
		bB = roundNum(-0.255814*x + 76.093);
	}
	else if(x == 188)
	{
		bB = 28;
	}
	else if(x >= 189 && x <= 217)
	{
		bB = roundNum(-0.535714*x + 131.25);
	}*/

	printf("%d %d %d\n", pB, sB, bB);
	
	primaryBalance = pB;
	secondaryBalance = sB;
	blurBalance = bB;
}
