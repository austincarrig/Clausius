//
//  RUSolver.m
//  Clausius
//
//  Created by Austin Carrig on 10/15/15.
//  Copyright © 2015 RowanApps. All rights reserved.
//

#import "RUSolver.h"

static const float M_WATER = 0.01801528; // Molar mass of water expressed in kg/mol
static const float T_CR = 647.0; // Critical temperature in K
static const float P_CR = 22100.0; // Critical pressure in kPA
static const float R_S = 0.48; // Gas constant in kJ/(kg.K)

@implementation RUSolver

// Solved using the Redlich-Kwong equation of state
+ (float)temperatureForSpecificVolume:(float)specVol andPressure:(float)pressure
{
    double Vm = (double)M_WATER*specVol; // Molar volume in m^3/mol

    double a = (double)0.4275 * powf(R_S, 2) * powf(T_CR, 2.5) / P_CR;
    double b = (double)0.08664 * R_S * T_CR / P_CR;

    double g = (double)R_S / (Vm - b);

    double h = a / (Vm * (Vm + b));

    double p = (double)pressure;

    double c = pow(27.*pow(g, 4.)*pow(h, 2.) - 2.*pow(g, 3.)*pow(p, 3.) + 3.*sqrt(3.)*sqrt(27.*pow(g, 8.)*pow(h, 4.) - 4.*pow(g, 7.)*pow(h, 2.)*pow(p, 3.)), 1./3.);

    float temp = (1./3.)*(pow(2., 1./3.)*pow(p, 2.)/c + c/(pow(2., 1./3.)*pow(g, 2.)) + 2.*p/g);

    return temp;
}

@end
