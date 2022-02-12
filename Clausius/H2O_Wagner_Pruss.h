//
//  H2O_Wagner_Pruss.h
//  PCG Pure Fluids
//
//  Created by Matthias Gottschalk on 8/19/10.
//  Copyright 2010 PhysChemGeo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface H2O_Wagner_Pruss : NSObject {
    
    /*
     Wagner & Pruß (2002)
     The IAPWS Formulation 1995 for the thermodynamic properties of ordinary water substance
     for general and scientific use. J.Phys.Chem.Ref.Data., 31, 387-535 
     */
    
    unsigned int count;
    
    NSString *fluidSpecies;
    NSString *fluidMethod;
    NSString *fluidTitle;
    NSString *fluidReference;
    
    double regularMinTemperature;
    double regularMaxTemperature;
    double regularMinPressure;
    double regularMaxPressure;
    double regularMinDensity;
    double regularMaxDensity;
    double regularMinVolume;
    double regularMaxVolume;
    double extrapolationMaxDensity;
    double extrapolationMaxPressure;
    double extrapolationMaxTemperature;
    double extrapolationMinVolume;
    
    double Tc, rhoc, Pc, Vc;
    double Ttrip, Ptrip, VtripL, VtripV, rhotripL, rhotripV;
    double R, Rm, M;
    double n_0[9], gamma_0[9];
    
    double c[57], d[57], t[57], n[57];
    double alpha[57], beta[57], gamma[57], epsilon[57];
    double a[57], b[57], B[57];
    double C[57], D[57], A[57];
    
    NSMutableString *error;
    NSString *debug;
    
    double coVolume;
	    
    NSString *messageEOS;
    NSMutableArray *isothermArray;

}

@property (copy) NSString *fluidSpecies;
@property (copy) NSString *fluidMethod;
@property (copy) NSString *fluidTitle;
@property (copy) NSString *fluidReference;

@property double regularMinTemperature;
@property double regularMaxTemperature;
@property double regularMinPressure;
@property double regularMaxPressure;
@property double regularMinDensity;
@property double regularMaxDensity;
@property double extrapolationMaxDensity;
@property double extrapolationMaxPressure;
@property double extrapolationMaxTemperature;
@property double regularMinVolume;
@property double regularMaxVolume;
@property double extrapolationMinVolume;

@property double Tc;
@property double Pc;
@property double Vc;
@property double rhoc;

@property double M;
@property double R;

@property double coVolume;

@property NSString       *messageEOS;
@property NSMutableArray *isothermArray;

#pragma mark -
#pragma mark Initilisation

// Designated Initializer
- (id)initEOS;

// print phi functions for test purposes
- (void)printVariablesWithTemperature:(double)temperature 
	    	    	       andDensity:(double)density;

#pragma mark -
#pragma mark Calculate tau, delta, and phi

// calculate tau
- (double)calculateTauWithTemperature:(double)temperature;

// calculate delta
- (double)calculateDeltaWithDensity:(double)density;

// calculate the ideal part of phi
- (double)calculatePhi_0WithTemperature:(double)temperature 
    	    	    	     andDensity:(double)density;

// calculate the ideal part of phi_0_delta
- (double)calculatePhi_0_deltaWithTemperature:(double)temperature 
	    	    	    	       andDensity:(double)density;

// calculate the ideal part of phi_0_delta_delta
- (double)calculatePhi_0_delta_deltaWithTemperature:(double)temperature 
	    	    	    	    	     andDensity:(double)density;

// calculate the ideal part of phi_0_tau
- (double)calculatePhi_0_tauWithTemperature:(double)temperature 
	    	    	    	     andDensity:(double)density;

// calculate the ideal part of phi_0_tau_tau
- (double)calculatePhi_0_tau_tauWithTemperature:(double)temperature 
    	    	    	    	     andDensity:(double)density;

// calculate the ideal part of phi_0_delta_tau
- (double)calculatePhi_0_delta_tauWithTemperature:(double)temperature 
    	    	    	    	       andDensity:(double)density;

// calculate the residual part of phi
- (double)calculatePhi_rWithTemperature:(double)temperature 
    	    	    	     andDensity:(double)density;

// calculate the residual part of phi_r_delta
- (double)calculatePhi_r_deltaWithTemperature:(double)temperature 
	    	    	    	       andDensity:(double)density;

// calculate the residual part of phi_r_delta_delta
- (double)calculatePhi_r_delta_deltaWithTemperature:(double)temperature 
	    	    	    	    	     andDensity:(double)density;

// calculate the residual part of phi_r_tau
- (double)calculatePhi_r_tauWithTemperature:(double)temperature 
	    	    	    	     andDensity:(double)density;

// calculate the residual part of phi_r_tau_tau
- (double)calculatePhi_r_tau_tauWithTemperature:(double)temperature 
    	    	    	    	     andDensity:(double)density;

// calculate the residual part of phi_r_delta_tau
- (double)calculatePhi_r_delta_tauWithTemperature:(double)temperature 
    	    	    	    	       andDensity:(double)density;

#pragma mark -
#pragma mark Calculate properties

// calculate pressure P as a function of delta and tau (density and temperature)
- (double)calculatePressureWithTemperature:(double)temperature 
	    	    	    	    andDensity:(double)density;

// calculate entropy S as a function of delta and tau (density and temperature)
- (double)calculateEntropyWithTemperature:(double)temperature 
    	    	    	       andDensity:(double)density;

// calculate internal energy U as a function of delta and tau (density and temperature)
- (double)calculateInternalEnergyWithTemperature:(double)temperature 
    	    	    	    	      andDensity:(double)density;

// calculate enthalpy H as a function of delta and tau (density and temperature)
- (double)calculateEnthalpyWithTemperature:(double)temperature 
	    	    	    	    andDensity:(double)density;

// calculate Helmholtz fee energy as a function of delta and tau (density and temperature)
- (double)calculateHelmholtzFreeEnergyWithTemperature:(double)temperature 
	    	    	    	    	       andDensity:(double)density;

// calculate Gibbs fee energy as a function of delta and tau (density and temperature)
- (double)calculateGibbsFreeEnergyWithTemperature:(double)temperature 
    	    	    	    	       andDensity:(double)density;

// calculate isochoric heat capacity cV as a function of delta and tau (density and temperature)
- (double)calculateCVWithTemperature:(double)temperature 
	    	    	      andDensity:(double)density;

// calculate isobaric heat capacity cP as a function of delta and tau (density and temperature)
- (double)calculateCPWithTemperature:(double)temperature 
	    	    	      andDensity:(double)density;

// calculate ideal isobaric heat capacity cPIdeal as a function of delta and tau (density and temperature)
- (double)calculateCPIdealWithTemperature:(double)temperature 
    	    	    	       andDensity:(double)density;

// calculate speed of sound W as a function of delta and tau (density and temperature)
- (double)calculateSpeedOfSoundWithTemperature:(double)temperature 
    	    	    	    	    andDensity:(double)density;

// calculate Joule-Thompson coefficient as a function of delta and tau (density and temperature)
- (double)calculateJoule_ThompsonCoefficientWithTemperature:(double)temperature 
	    	    	    	    	    	     andDensity:(double)density;

// calculate isothermal throttling coefficient as a function of delta and tau (density and temperature)
- (double)calculateIsothermalThrottlingCoefficientWithTemperature:(double)temperature 
    	    	    	    	    	    	       andDensity:(double)density;

// calculate isentropic temperature-pressure coefficient as a function of delta and tau (density and temperature)
- (double)calculateIsentropicTemperaturePressureCoefficientWithTemperature:(double)temperature 
	    	    	    	    	    	    	    	    andDensity:(double)density;

// calculate second virial coefficient as a function of tau (temperature)
- (double)calculateSecondVirialCoefficientWithTemperature:(double)temperature;

// calculate third virial coefficient as a function of tau (temperature)
- (double)calculateThirdVirialCoefficientWithTemperature:(double)temperature;

// calculate Z
- (double)calculateZWithTemperature:(double)temperature
	    	    	    andPressure:(double)pressure 
	    	    	     andDensity:(double)density;

// calculate Fugacity
- (double)calculateFugacityWithTemperature:(double)temperature 
    	    	    	       andPressure:(double)pressure 
	    	    	    	    andDensity:(double)density;

// calculate Fugacity Coefficient
- (double)calculateFugacityCoefficientWithTemperature:(double)temperature 
	    	    	    	    	      andPressure:(double)pressure 
	    	    	    	    	       andDensity:(double)density;

// calculate isobaric expansion coefficient alpha
- (double)calculateIsobaricExpansionCoefficientWithTemperature:(double)temperature 
    	    	    	    	    	    	    andDensity:(double)density; 

// calculate isothermal compressibilty beta
- (double)calculateIsothermalCompressibiltyWithTemperature:(double)temperature 
    	    	    	    	    	    	    andDensity:(double)density;

// calculate relative pressure coefficient alphaP
- (double)calculateRelativePressureCoefficientWithTemperature:(double)temperature 
	    	    	    	    	    	      andPressure:(double)pressure
	    	    	    	    	    	       andDensity:(double)density;

// calculate isothermal stress coefficient betaP
- (double)calculateIsothermalStressCoefficientWithTemperature:(double)temperature 
	    	    	    	    	    	      andPressure:(double)pressure
	    	    	    	    	    	       andDensity:(double)density;


// calculate nearly all values
- (NSMutableDictionary *)calculateAllWithTemperature:(double)temperature 
	    	    	    	    	      andDensity:(double)density;

// calculate selected values
- (id)calculatePropertiesFor:(NSString *)property
             withTemperature:(double)temperature
                 andPressure:(double)pressure
                  andDensity:(double)density;


#pragma mark -
#pragma mark Additional functions

// calculate liquid density at the liquid-vapor curve
- (double)liquidDensityAtSaturation:(double)temperature;

// calculate vapor density at the liquid-vapor curve
- (double)vaporDensityAtSaturation:(double)temperature;

// calculate pressure at the liuid-vapor curve
- (double)pressureVapourLiquidWithTemperature:(double)temperature;

- (double)temperatureVapourLiquidWithPressure:(double)pressure;

// calculate rho for pressure and temperature
- (double)rhoWithTemperature:(double)temperature 
	    	     andPressure:(double)pressure;

// find rho
- (double)findRhoWithTemperature:(double)temperature 
    	    	     andPressure:(double)pressure
    	      andDensityEstimate:(double)density;

// calculate accurate pressure at the liuid-vapor curve
- (NSArray *)accuratePressureVapourLiquidWithTemperature:(double)temperature;

// calculate accurate temperature at the liuid-vapor curve
- (NSArray *)accurateTemperatureVapourLiquidWithPressure:(double)pressure;

@end
