//
//  H2O_Wagner_Pruss.m
//  PCG Pure Fluids
//
//  Created by Matthias Gottschalk on 8/19/10.
//  Copyright 2010 PhysChemGeo. All rights reserved.
//

#import "H2O_Wagner_Pruss.h"

@implementation H2O_Wagner_Pruss

/*
 Wagner & Pruß (2002)
 The IAPWS formulation 1995 for the thermodynamic properties of ordinary water substance
 for general and scientific use. J.Phys.Chem.Ref.Data., 31, 387-535 
 */	

@synthesize fluidSpecies;
@synthesize fluidMethod;
@synthesize fluidTitle;
@synthesize fluidReference;

@synthesize regularMinTemperature;
@synthesize regularMaxTemperature;
@synthesize regularMinPressure;
@synthesize regularMaxPressure;
@synthesize regularMinDensity;
@synthesize regularMaxDensity;
@synthesize extrapolationMaxDensity;
@synthesize extrapolationMaxPressure;
@synthesize extrapolationMaxTemperature;
@synthesize regularMinVolume;
@synthesize regularMaxVolume;
@synthesize extrapolationMinVolume;


@synthesize Tc;
@synthesize Pc;
@synthesize Vc;
@synthesize rhoc;

@synthesize M;
@synthesize R;

@synthesize coVolume;

@synthesize messageEOS;
@synthesize isothermArray;


#pragma mark -
#pragma mark Initilisation

// Designated Initializer
- (id)initEOS
{
	self = [super init];
	
	if (nil != self) {
		
        messageEOS = @"";
        isothermArray = [NSMutableArray arrayWithObjects: [NSNumber numberWithDouble:  600],
                                                          [NSNumber numberWithDouble:  700],
                                                          [NSNumber numberWithDouble:  800],
                                                          [NSNumber numberWithDouble: 1000],
                                                          [NSNumber numberWithDouble: 1300],
                                                          nil];

		fluidSpecies   = @"H2O";
		fluidMethod    = @"Wagner & Pruß (2002)";
		fluidTitle     = @"The IAPWS formulation 1995 for the thermodynamic properties of ordinary water substance for general and scientific use";
		fluidReference = @"Journal of Physical and Chemical Reference Data, 31, 387-535";
		
		regularMinTemperature       =    250.;   // K
		regularMaxTemperature       =   1273.;   // K
		extrapolationMaxTemperature =   7000.;   // K
		regularMinPressure          = 1.E-200;   // MPa
		regularMaxPressure          =   1000.;   // MPa
		extrapolationMaxPressure    = 100000.;   // MPa;
		regularMinDensity           = 1.E-200;   // kg/m^3
		regularMaxDensity           =   1300.;   // kg/m^3
		extrapolationMaxDensity     =   2500.;   // kg/m^3
        regularMinVolume            = 1./regularMaxDensity;       // m^3/kg
        regularMaxVolume            = 1.E+200;                    // m^3/kg
        extrapolationMinVolume      = 1./extrapolationMaxDensity; // m^3/kg
		
		
		error = [[NSMutableString alloc] initWithString:@"no error"];
		debug = @"nodebug";
		
		Tc			= 647.096;    // K
		rhoc		= 322.;       // kg/m^3
		Pc			= 22.064;     // MPa
		R			= 0.46151805; // kJ/kg/K Rm/M
		M			= 18.015268;  // g/mol
		Rm			= R * M;
		Vc			= 1. / rhoc;
        
        coVolume    = 30.49 / (M * 1000.) ; // m^3/kg


		
		Ttrip       = 273.16;
		Ptrip       = 0.000611655;
		rhotripL    = 999.793;
		rhotripV    = 0.00485458;
        VtripL      = 1. / rhotripL;
		VtripV      = 1. / rhotripV; 

		
		
		n_0[1]	= -8.32044648201;
		n_0[2]	=  6.6832105268;
		n_0[3]	=  3.00632;
		n_0[4]	=  0.012436;
		n_0[5]	=  0.97315;
		n_0[6]	=  1.27950;
		n_0[7]	=  0.96956;
		n_0[8]	=  0.24873;
        		
		gamma_0[4]	=  1.28728967;
		gamma_0[5]	=  3.53734222;
		gamma_0[6]	=  7.74073708;
		gamma_0[7]	=  9.24437796;
		gamma_0[8]	= 27.5075105;
		
		beta[52]	= 150.;
		beta[53]	= 150.;
		beta[54]	= 250.;
		
		gamma[52]	= 1.21;
		gamma[53]	= 1.21;
		gamma[54]	= 1.25;
		
		alpha[52]	= 20.;
		alpha[53]	= 20.;
		alpha[54]	= 20.;
		
		epsilon[52]	= 1.;
		epsilon[53]	= 1.;
		epsilon[54]	= 1.;
		
		a[55]		= 3.5;
		a[56]		= 3.5;
		
		b[55]		= 0.85;
		b[56]		= 0.95;
		
		A[55]		= 0.32;
		A[56]		= 0.32;
		B[55]		= 0.2;
		B[56]		= 0.2;
		C[55]		= 28.;
		C[56]		= 32.;
		D[55]		= 700.;
		D[56]		= 800.;
		beta[55]	= 0.3;
		beta[56]	= 0.3;
		
		for (int i = 8; i <= 22;  ++i) c[i] = 1.;
		for (int i = 23; i <= 42; ++i) c[i] = 2.;
		for (int i = 43; i <= 46; ++i) c[i] = 3.;
        
        c[47]= 4.;
		
        for (int i = 48; i <= 51; ++i) c[i] = 6.;
		
		d[1]  =  1.;
		d[2]  =  1.;
		d[3]  =  1.;
		d[4]  =  2.;
		d[5]  =  2.;
		d[6]  =  3.;
		d[7]  =  4.;
		d[8]  =  1.;
		d[9]  =  1.;
		d[10] =  1.;
		d[11] =  2.;
		d[12] =  2.;
		d[13] =  3.;
		d[14] =  4.;
		d[15] =  4.;
		d[16] =  5.;
		d[17] =  7.;
		d[18] =  9.;
		d[19] = 10.;
		d[20] = 11.;
		d[21] = 13.;
		d[22] = 15.;
		d[23] =  1.;
		d[24] =  2.;
		d[25] =  2.;
		d[26] =  2.;
		d[27] =  3.;
		d[28] =  4.;
		d[29] =  4.;
		d[30] =  4.;
		d[31] =  5.;
		d[32] =  6.;
		d[33] =  6.;
		d[34] =  7.;
		d[35] =  9.;
		d[36] =  9.;
		d[37] =  9.;
		d[38] =  9.;
		d[39] =  9.;
		d[40] = 10.;
		d[41] = 10.;
		d[42] = 12.;
		d[43] =  3.;
		d[44] =  4.;
		d[45] =  4.;
		d[46] =  5.;
		d[47] = 14.;
		d[48] =  3.;
		d[49] =  6.;
		d[50] =  6.;
		d[51] =  6.;
		d[52] =  3.;
		d[53] =  3.;
		d[54] =  3.;
		
		t[1]  = -0.5;
		t[2]  =  0.875;
		t[3]  =  1.;
		t[4]  =  0.5;
		t[5]  =  0.75;
		t[6]  =  0.375;
		t[7]  =  1.;
		t[8]  =  4.;
		t[9]  =  6.;
		t[10] = 12.;
		t[11] =  1.;
		t[12] =  5.;
		t[13] =  4.;
		t[14] =  2.;
		t[15] = 13.;
		t[16] =  9.;
		t[17] =  3.;
		t[18] =  4.;
		t[19] = 11.;
		t[20] =  4.;
		t[21] = 13.;
		t[22] =  1.;
		t[23] =  7.;
		t[24] =  1.;
		t[25] =  9.;
		t[26] = 10.;
		t[27] = 10.;
		t[28] =  3.;
		t[29] =  7.;
		t[30] = 10.;
		t[31] = 10.;
		t[32] =  6.;
		t[33] = 10.;
		t[34] = 10.;
		t[35] =  1.;
		t[36] =  2.;
		t[37] =  3.;
		t[38] =  4.;
		t[39] =  8.;
		t[40] =  6.;
		t[41] =  9.;
		t[42] =  8.;
		t[43] = 16.;
		t[44] = 22.;
		t[45] = 23.;
		t[46] = 23.;
		t[47] = 10.;
		t[48] = 50.;
		t[49] = 44.;
		t[50] = 46.;
		t[51] = 50.;
		t[52] =  0.;
		t[53] =  1.;
		t[54] =  4.;
		
		n[1]  =  0.12533547935523e-1;
		n[2]  =  0.78957634722828e1;
		n[3]  = -0.87803203303561e1;
		n[4]  =  0.31802509345418;
		n[5]  = -0.26145533859358;
		n[6]  = -0.78199751687981e-2;
		n[7]  =  0.88089493102134e-2;
		n[8]  = -0.66856572307965;
		n[9]  =  0.20433810950965;
		n[10] = -0.66212605039687e-4;
		n[11] = -0.19232721156002;
		n[12] = -0.25709043003438;
		n[13] =  0.16074868486251;
		n[14] = -0.40092828925807e-1;
		n[15] =  0.39343422603254e-6;
		n[16] = -0.75941377088144e-5;
		n[17] =  0.56250979351888e-3;
		n[18] = -0.15608652257135e-4;
		n[19] =  0.11537996422951e-8;
		n[20] =  0.36582165144204e-6;
		n[21] = -0.13251180074668e-11;
		n[22] = -0.62639586912454e-9;
		n[23] = -0.10793600908932;
		n[24] =  0.17611491008752e-1;
		n[25] =  0.22132295167546;
		n[26] = -0.40247669763528;
		n[27] =  0.58083399985759;
		n[28] =  0.49969146990806e-2;
		n[29] = -0.31358700712549e-1;
		n[30] = -0.74315929710341;
		n[31] =  0.47807329915480;
		n[32] =  0.20527940895948e-1;
		n[33] = -0.13636435110343;
		n[34] =  0.14180634400617e-1;
		n[35] =  0.83326504880713e-2;
		n[36] = -0.29052336009585e-1;
		n[37] =  0.38615085574206e-1;
		n[38] = -0.20393486513704e-1;
		n[39] = -0.16554050063734e-2;
		n[40] =  0.19955571979541e-2;
		n[41] =  0.15870308324157e-3;
		n[42] = -0.16388568342530e-4;
		n[43] =  0.43613615723811e-1;
		n[44] =  0.34994005463765e-1;
		n[45] = -0.76788197844621e-1;
		n[46] =  0.22446277332006e-1;
		n[47] = -0.62689710414685e-4;
		n[48] = -0.55711118565645e-9;
		n[49] = -0.19905718354408;
		n[50] =  0.31777497330738;
		n[51] = -0.11841182425981;
		n[52] = -0.31306260323435e2;
		n[53] =  0.31546140237781e2;
		n[54] = -0.25213154341695e4;
		n[55] = -0.14874640856724;
		n[56] =  0.31806110878444;
	
	}
	
	return self;	
}


// Overriden inherited Designated Initializer
- (id)init
{
	// call Designated Initializer with default arguments
	return[self initEOS];
}


// dealloc
//- (void)dealloc
//{
//	[super dealloc];
//}


// print phi functions for test purposes
- (void)printVariablesWithTemperature:(double)temperature 
						   andDensity:(double)density
{
	double tau, delta;
	double phi_0, phi_0_delta, phi_0_delta_delta, phi_0_tau, phi_0_tau_tau, phi_0_delta_tau;
	double phi_r, phi_r_delta, phi_r_delta_delta, phi_r_tau, phi_r_tau_tau, phi_r_delta_tau;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];

	// calculate derivates
	phi_0             = [self calculatePhi_0WithTemperature:temperature 
												 andDensity:density];
	phi_0_delta       = [self calculatePhi_0_deltaWithTemperature:temperature 
													   andDensity:density];
	phi_0_delta_delta = [self calculatePhi_0_delta_deltaWithTemperature:temperature 
															 andDensity:density];
	phi_0_tau         = [self calculatePhi_0_tauWithTemperature:temperature 
													 andDensity:density];
	phi_0_tau_tau     = [self calculatePhi_0_tau_tauWithTemperature:temperature 
														 andDensity:density];
	phi_0_delta_tau   = [self calculatePhi_0_delta_tauWithTemperature:temperature 
														   andDensity:density];
	
	phi_r             = [self calculatePhi_rWithTemperature:temperature 
												 andDensity:density];
	phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:density];
	phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature 
															 andDensity:density];
	phi_r_tau         = [self calculatePhi_r_tauWithTemperature:temperature 
													 andDensity:density];
	phi_r_tau_tau     = [self calculatePhi_r_tau_tauWithTemperature:temperature 
														 andDensity:density];
	phi_r_delta_tau   = [self calculatePhi_r_delta_tauWithTemperature:temperature 
														   andDensity:density];
	
	NSLog(@" ");
	NSLog(@"delta:             %17.16f", delta);
	NSLog(@"tau:               %17.16f", tau);
	NSLog(@" ");
	NSLog(@"phi_0:             %17.16f", phi_0);
	NSLog(@"phi_0_delta:       %17.16f", phi_0_delta);
	NSLog(@"phi_0_delta_delta: %17.16f", phi_0_delta_delta);
	NSLog(@"phi_0_tau:         %17.16f", phi_0_tau);
	NSLog(@"phi_0_tau_tau:     %17.16f", phi_0_tau_tau);
	NSLog(@"phi_0_delta_tau:   %17.16f", phi_0_delta_tau);
	NSLog(@" ");
	NSLog(@"phi_r:             %17.16f", phi_r);
	NSLog(@"phi_r_delta:       %17.16f", phi_r_delta);
	NSLog(@"phi_r_delta_delta: %17.16f", phi_r_delta_delta);
	NSLog(@"phi_r_tau:         %17.16f", phi_r_tau);
	NSLog(@"phi_r_tau_tau:     %17.16f", phi_r_tau_tau);
	NSLog(@"phi_r_delta_tau:   %17.16f", phi_r_delta_tau);
	
}

#pragma mark -
#pragma mark Calculate tau, delta, and phi

// calculate tau
- (double)calculateTauWithTemperature:(double)temperature
{
	double tau;
	tau = Tc/temperature;
	
	return tau;
}


// calculate delta
- (double)calculateDeltaWithDensity:(double)density

{
	double delta;
	delta = density/rhoc;
	
	return delta;
}


// calculate the ideal part of phi
- (double)calculatePhi_0WithTemperature:(double)temperature 
							 andDensity:(double)density
{	
	double phi_0, tau, delta;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
	
	phi_0 = log(delta) + n_0[1] + n_0[2] * tau + n_0[3] * log(tau);
	for ( int i = 4; i <= 8; ++i )
		phi_0 = phi_0 + n_0[i] * log( 1. - exp(-gamma_0[i] * tau) );
	
	return phi_0;
}


// calculate the ideal part of phi_0_delta
- (double)calculatePhi_0_deltaWithTemperature:(double)temperature 
								   andDensity:(double)density
{	
	double phi_0_delta, delta;
	
	delta = [self calculateDeltaWithDensity:density];
	
	phi_0_delta = 1./delta;
	
	return phi_0_delta;
}


// calculate the ideal part of phi_0_delta_delta
- (double)calculatePhi_0_delta_deltaWithTemperature:(double)temperature 
										 andDensity:(double)density
{
	double phi_0_delta_delta, delta;
	
	delta = [self calculateDeltaWithDensity:density];

	phi_0_delta_delta = -1./(delta * delta);
	
	return phi_0_delta_delta;
}


// calculate the ideal part of phi_0_tau
- (double)calculatePhi_0_tauWithTemperature:(double)temperature 
								 andDensity:(double)density
{	
	double phi_0_tau, tau;
	
	tau   = [self calculateTauWithTemperature:temperature];

	phi_0_tau = n_0[2] + n_0[3]/tau;
	for ( int i = 4; i <= 8; ++i )
		phi_0_tau = phi_0_tau + n_0[i] * gamma_0[i] * (1./( 1. - exp(-gamma_0[i] * tau) )- 1.);
	
	return phi_0_tau;
}


// calculate the ideal part of phi_0_tau_tau
- (double)calculatePhi_0_tau_tauWithTemperature:(double)temperature 
									 andDensity:(double)density
{	
	double phi_0_tau_tau, tau;
	
	tau   = [self calculateTauWithTemperature:temperature];
	
	phi_0_tau_tau = -n_0[3]/(tau * tau);
	for ( int i = 4; i <= 8; ++i )
		phi_0_tau_tau = phi_0_tau_tau - n_0[i] * gamma_0[i] * gamma_0[i] * exp(-gamma_0[i] * tau) 
		* (1./( (1. - exp(-gamma_0[i] * tau)) *  (1. - exp(-gamma_0[i] * tau)) ));
	
	return phi_0_tau_tau;
}


// calculate the ideal part of phi_0_delta_tau
- (double)calculatePhi_0_delta_tauWithTemperature:(double)temperature 
									   andDensity:(double)density
{
	double phi_0_delta_tau;
		
	phi_0_delta_tau = 0.;
	
	return phi_0_delta_tau;
}


// calculate the residual part of phi
- (double)calculatePhi_rWithTemperature:(double)temperature 
							 andDensity:(double)density
{
	double phi_r, tau, delta;
	double gdelta, theta, psi;

	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
	
	phi_r = 0.;
	for ( int i = 1; i <= 7; ++i )
		phi_r = phi_r + n[i] * pow(delta, d[i]) * pow(tau, t[i]);
	for ( int i = 8; i <= 51; ++i )
		phi_r = phi_r + n[i] * pow(delta, d[i]) * pow(tau, t[i]) * exp(-pow(delta, c[i]));
	for ( int i = 52; i <= 54; ++i ) 
		phi_r = phi_r + n[i] * pow(delta, d[i]) * pow(tau, t[i]) * exp(-alpha[i] * pow(delta - epsilon[i],2.) - beta[i] * pow(tau - gamma[i],2.));
	for ( int i = 55; i <= 56; ++i ) {		
		// definition of theta, gdelta, psi
		theta  = (1. - tau) + A[i] * pow((delta - 1.) * (delta - 1.),1./(2. * beta[i]));
		gdelta = theta * theta + B[i] * pow((delta - 1.) * (delta - 1.), a[i]);
		psi = exp(-C[i] * (delta - 1.) * (delta - 1.) - D[i] * (tau - 1.) * (tau - 1.));
		phi_r = phi_r + n[i] * pow(gdelta, b[i]) * delta * psi;
	}
	
	return phi_r;
}


// calculate the residual part of phi_r_delta
- (double)calculatePhi_r_deltaWithTemperature:(double)temperature 
								   andDensity:(double)density
{
	double phi_r_delta, tau, delta;
	double gdelta, theta, psi;
	double gdelta_delta, gdelta_bi_delta;
	double psi_delta;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
		
	phi_r_delta = 0.;
	for ( int i = 1; i <= 7; ++i )
		phi_r_delta = phi_r_delta + n[i] * d[i] * pow(delta, d[i] - 1.) * pow(tau, t[i]);
	for ( int i = 8; i <= 51; ++i )
		phi_r_delta = phi_r_delta + n[i] * exp(-pow(delta, c[i])) * ( pow(delta, d[i] - 1.) * pow(tau, t[i]) * (d[i] - c[i] * pow(delta, c[i])) );
	for ( int i = 52; i <= 54; ++i ) 
		phi_r_delta = phi_r_delta + n[i] * pow(delta, d[i]) * pow(tau, t[i]) * exp(-alpha[i] * pow(delta - epsilon[i],2.) - beta[i] * pow(tau - gamma[i],2.)) 
		        * (d[i]/delta - 2. * alpha[i] * (delta - epsilon[i]));
	for ( int i = 55; i <= 56; ++i ) {	
		// definition of theta, gdelta, psi
		theta  = (1. - tau) + A[i] * pow((delta - 1.) * (delta - 1.),1./(2. * beta[i]));
		gdelta = theta * theta + B[i] * pow((delta - 1.) * (delta - 1.), a[i]);
		psi = exp(-C[i] * (delta - 1.) * (delta - 1.) - D[i] * (tau - 1.) * (tau - 1.));		
		// definition of gdelta_delta, gdelta_bi_delta
		gdelta_delta = (delta - 1.) * (A[i] * theta * 2./beta[i] * pow((delta - 1.)*(delta - 1.), 1./(2. * beta[i]) - 1.) 
						+ 2. * B[i] * a[i] * pow((delta - 1.)*(delta - 1.), a[i] - 1.));
		gdelta_bi_delta = b[i] * pow(gdelta, b[i] - 1.) * gdelta_delta;	
		// definition of psi_delta
		psi_delta = -2. * C[i] * (delta - 1.) * psi;
		phi_r_delta = phi_r_delta + n[i] * (pow(gdelta, b[i]) * (psi + delta * psi_delta) + gdelta_bi_delta * delta * psi);
	}
	
	return phi_r_delta;
}


// calculate the residual part of phi_r_delta_delta
- (double)calculatePhi_r_delta_deltaWithTemperature:(double)temperature 
										 andDensity:(double)density
{
	double phi_r_delta_delta, tau, delta;
	double gdelta, theta, psi;
	double gdelta_delta, gdelta_delta_delta, gdelta_bi_delta, gdelta_bi_delta_delta;
	double psi_delta, psi_delta_delta;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
		
	phi_r_delta_delta = 0.;
	for ( int i = 1; i <= 7; ++i )
		phi_r_delta_delta = phi_r_delta_delta + n[i] * d[i] * (d[i] - 1.) * pow(delta, d[i] - 2.) * pow(tau, t[i]);
	for ( int i = 8; i <= 51; ++i )
		phi_r_delta_delta = phi_r_delta_delta + n[i] * exp(-pow(delta, c[i])) * ( pow(delta, d[i] - 2.) * pow(tau, t[i])
				* ((d[i] - c[i] * pow(delta, c[i])) * (d[i] - 1. - c[i] * pow(delta, c[i])) - c[i]*c[i] * pow(delta, c[i])) );
	for ( int i = 52; i <= 54; ++i ) 
		phi_r_delta_delta = phi_r_delta_delta + n[i] * pow(tau, t[i]) * exp(-alpha[i] * pow(delta - epsilon[i],2.) - beta[i] * pow(tau - gamma[i],2.)) 
		        * (- 2. * alpha[i] * pow(delta, d[i]) 
				   + 4. * alpha[i]*alpha[i] * pow(delta, d[i]) * (delta - epsilon[i])*(delta - epsilon[i])
				   - 4. * d[i] * alpha[i] * pow(delta, d[i] - 1.) * (delta - epsilon[i]) 
				   + d[i]*(d[i] - 1.) * pow(delta, d[i] - 2.));
	for ( int i = 55; i <= 56; ++i ) {	
		// definition of theta, gdelta, psi
		theta  = (1. - tau) + A[i] * pow((delta - 1.) * (delta - 1.),1./(2. * beta[i]));
		gdelta = theta * theta + B[i] * pow((delta - 1.) * (delta - 1.), a[i]);
		psi = exp(-C[i] * (delta - 1.) * (delta - 1.) - D[i] * (tau - 1.) * (tau - 1.));		
		// definition of gdelta_delta, gdelta_bi_delta, gdelta_delta_delta, gdelta_bi_delta_delta
		gdelta_delta = (delta - 1.) * (A[i] * theta * 2./beta[i] * pow((delta - 1.)*(delta - 1.), 1./(2. * beta[i]) - 1.) 
									   + 2. * B[i] * a[i] * pow((delta - 1.)*(delta - 1.), a[i] - 1.));
		gdelta_delta_delta = 1./(delta - 1.) * gdelta_delta + (delta - 1.)*(delta - 1.)
							   * (4. * B[i] * a[i] * (a[i] - 1.) * pow((delta - 1.)*(delta - 1.), a[i] - 2.) 
							   + 2. * A[i]*A[i] * (1./beta[i])*(1./beta[i]) * (pow((delta - 1.)*(delta - 1.),1./(2. * beta[i]) - 1.)) 
																			* (pow((delta - 1.)*(delta - 1.),1./(2. * beta[i]) - 1.))
							   + A[i] * theta * 4./beta[i] * (1./(2. * beta[i]) - 1.) * pow((delta - 1.)*(delta - 1.), 1./(2. * beta[i]) - 2.) );		
		gdelta_bi_delta = b[i] * pow(gdelta, b[i] - 1.) * gdelta_delta;
		gdelta_bi_delta_delta = b[i] * (pow(gdelta, b[i] - 1.) * gdelta_delta_delta + (b[i] - 1.) * pow(gdelta, b[i] - 2.) * gdelta_delta*gdelta_delta);
		// definition of psi_delta, psi_delta_delta
		psi_delta = -2. * C[i] * (delta - 1.) * psi;
		psi_delta_delta = (2. * C[i] * (delta - 1.)*(delta - 1.) - 1.) * 2. * C[i] * psi;
		phi_r_delta_delta = phi_r_delta_delta + n[i] * (pow(gdelta, b[i]) 
													 * (2. * psi_delta + delta * psi_delta_delta) + 2. * gdelta_bi_delta 
														* (psi + delta * psi_delta) + gdelta_bi_delta_delta * delta * psi);
	}
	
	return phi_r_delta_delta;
}


// calculate the residual part of phi_r_tau
- (double)calculatePhi_r_tauWithTemperature:(double)temperature 
								 andDensity:(double)density
{
	double phi_r_tau, tau, delta;
	double gdelta, theta, psi;
	double gdelta_bi_tau, psi_tau;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
	
	phi_r_tau = 0.;
	for ( int i = 1; i <= 7; ++i )
		phi_r_tau = phi_r_tau + n[i] * t[i] * pow(delta, d[i]) * pow(tau, t[i] - 1.);
	for ( int i = 8; i <= 51; ++i )
		phi_r_tau = phi_r_tau + n[i] * t[i] * pow(delta, d[i]) * pow(tau, t[i] - 1.) * exp(-pow(delta, c[i]));
	for ( int i = 52; i <= 54; ++i ) 
		phi_r_tau = phi_r_tau + n[i] * pow(delta, d[i]) * pow(tau, t[i]) * exp(-alpha[i] * pow(delta - epsilon[i],2.) - beta[i] * pow(tau - gamma[i],2.)) 
		       * (t[i]/tau - 2. * beta[i] * (tau - gamma[i]));
	for ( int i = 55; i <= 56; ++i ) {		
		// definition of theta, gdelta, psi
		theta  = (1. - tau) + A[i] * pow((delta - 1.) * (delta - 1.),1./(2. * beta[i]));
		gdelta = theta * theta + B[i] * pow((delta - 1.) * (delta - 1.), a[i]);
		psi = exp(-C[i] * (delta - 1.) * (delta - 1.) - D[i] * (tau - 1.) * (tau - 1.));
		// definition gdelta_bi_tau, psi_tau
		gdelta_bi_tau = -2. * theta * b[i] * pow(gdelta, b[i] - 1.);
		psi_tau = -2. * D[i] * (tau - 1.) * psi;
		phi_r_tau = phi_r_tau + n[i] * delta * (gdelta_bi_tau * psi + pow(gdelta, b[i]) * psi_tau);
	}
	
	return phi_r_tau;
}


// calculate the residual part of phi_r_tau_tau
- (double)calculatePhi_r_tau_tauWithTemperature:(double)temperature 
									 andDensity:(double)density
{
	double phi_r_tau_tau, tau, delta;
	double gdelta, theta, psi;
	double gdelta_bi_tau, gdelta_bi_tau_tau, psi_tau, psi_tau_tau;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
	
	phi_r_tau_tau = 0.;
	for ( int i = 1; i <= 7; ++i )
		phi_r_tau_tau = phi_r_tau_tau + n[i] * t[i] * (t[i] - 1.) * pow(delta, d[i]) * pow(tau, t[i] - 2.);
	for ( int i = 8; i <= 51; ++i )
		phi_r_tau_tau = phi_r_tau_tau + n[i] * t[i] * (t[i] - 1.)* pow(delta, d[i]) * pow(tau, t[i] - 2.) * exp(-pow(delta, c[i]));
	for ( int i = 52; i <= 54; ++i ) 		
		phi_r_tau_tau = phi_r_tau_tau + n[i] * pow(delta, d[i]) * pow(tau, t[i]) * exp(-alpha[i] * pow(delta - epsilon[i],2.) - beta[i] * pow(tau - gamma[i],2.)) 
		* ( (t[i]/tau - 2. * beta[i] * (tau - gamma[i]))*(t[i]/tau - 2. * beta[i] * (tau - gamma[i])) - t[i]/(tau*tau) - 2. * beta[i] );
	for ( int i = 55; i <= 56; ++i ) {		
		// definition of theta, gdelta, psi
		theta  = (1. - tau) + A[i] * pow((delta - 1.) * (delta - 1.),1./(2. * beta[i]));
		gdelta = theta * theta + B[i] * pow((delta - 1.) * (delta - 1.), a[i]);
		psi = exp(-C[i] * (delta - 1.) * (delta - 1.) - D[i] * (tau - 1.) * (tau - 1.));
		// definition gdelta_bi_tau, psi_tau, psi_tau_tau
		gdelta_bi_tau = -2. * theta * b[i] * pow(gdelta, b[i] - 1.);
		gdelta_bi_tau_tau = 2. * b[i] * pow(gdelta, b[i] - 1.) + 4. * theta*theta * b[i] * (b[i] - 1.) * pow(gdelta, b[i] - 2.);
		psi_tau = -2. * D[i] * (tau - 1.) * psi;
		psi_tau_tau = 2. * D[i] * psi * (2. * D[i] * (tau  - 1.)* (tau  - 1.) - 1.);
		phi_r_tau_tau = phi_r_tau_tau + n[i] * delta * (gdelta_bi_tau_tau * psi + 2. * gdelta_bi_tau * psi_tau + pow(gdelta, b[i]) * psi_tau_tau);
	}	
	
	return phi_r_tau_tau;
}


// calculate the ideal part of phi_r_delta_tau
- (double)calculatePhi_r_delta_tauWithTemperature:(double)temperature 
									   andDensity:(double)density
{
	double phi_r_delta_tau, tau, delta;
	double gdelta, theta, psi;
	double gdelta_bi_delta, gdelta_bi_tau, gdelta_bi_delta_tau, gdelta_delta, psi_tau, psi_delta, psi_delta_tau;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
	
	phi_r_delta_tau = 0.;
	for ( int i = 1; i <= 7; ++i )
		phi_r_delta_tau = phi_r_delta_tau + n[i] * d[i]* t[i] * pow(delta, d[i] - 1.) * pow(tau, t[i] - 1.);
	for ( int i = 8; i <= 51; ++i )
		phi_r_delta_tau = phi_r_delta_tau + n[i] * t[i] * pow(delta, d[i] - 1.) * pow(tau, t[i] - 1.) * (d[i] - c[i] * pow(delta, c[i])) * exp(-pow(delta, c[i]));
	for ( int i = 52; i <= 54; ++i ) 
		phi_r_delta_tau = phi_r_delta_tau + n[i] * pow(delta, d[i]) * pow(tau, t[i]) * exp(-alpha[i] * pow(delta - epsilon[i],2.) - beta[i] * pow(tau - gamma[i],2.)) 
		* (d[i]/delta - 2. * alpha[i] * (delta - epsilon[i])) * (t[i]/tau - 2. * beta[i] * (tau - gamma[i]));
	for ( int i = 55; i <= 56; ++i ) {	
		// definition of theta, gdelta, psi
		theta  = (1. - tau) + A[i] * pow((delta - 1.) * (delta - 1.),1./(2. * beta[i]));
		gdelta = theta * theta + B[i] * pow((delta - 1.) * (delta - 1.), a[i]);
		psi = exp(-C[i] * (delta - 1.) * (delta - 1.) - D[i] * (tau - 1.) * (tau - 1.));
		// definition gdelta_bi_delta, gdelta_bi_tau, gdelta_delta, psi_delta, psi_tau
		gdelta_delta = (delta - 1.) * (A[i] * theta * 2./beta[i] * pow((delta - 1.)*(delta - 1.), 1./(2. * beta[i]) - 1.) 
									   + 2. * B[i] * a[i] * pow((delta - 1.)*(delta - 1.), a[i] - 1.));
		gdelta_bi_delta = b[i] * pow(gdelta, b[i] - 1.) * gdelta_delta;
		gdelta_bi_tau = -2. * theta * b[i] * pow(gdelta, b[i] - 1.);
		gdelta_bi_delta_tau = -A[i] * b[i] * 2./beta[i] * pow(gdelta, b[i] - 1.) * (delta - 1.) * pow((delta - 1.)*(delta - 1.), 1/(2. * beta[i]) - 1.) 
		                      - 2. * theta * b[i] * (b[i] - 1.) * pow(gdelta, b[i] - 2.) * gdelta_delta;		
		psi_tau = -2. * D[i] * (tau - 1.) * psi;
		psi_delta = -2. * C[i] * (delta - 1.) * psi;
		psi_delta_tau = 4. * C[i] * D[i] * (delta - 1.) * (tau - 1.) * psi;
		phi_r_delta_tau = phi_r_delta_tau + n[i] * ( pow(gdelta, b[i]) * (psi_tau + delta * psi_delta_tau) 
								+ delta * gdelta_bi_delta * psi_tau 
								+ gdelta_bi_tau * (psi + delta * psi_delta)
								+ gdelta_bi_delta_tau * delta * psi);
	}
	
	return phi_r_delta_tau;
}


#pragma mark -
#pragma mark Calculate properties
																	  
// pressure P as a function of delta and tau (density and temperature)
- (double)calculatePressureWithTemperature:(double)temperature 
								andDensity:(double)density;
{
	double delta;
	double rho;
	double pressure, phi_r_delta;
	
	delta = [self calculateDeltaWithDensity:density];
	
	rho = delta * rhoc;
	phi_r_delta = [self calculatePhi_r_deltaWithTemperature:temperature 
												 andDensity:density]; 
	
	pressure = rho * R * temperature * (1. + delta * phi_r_delta)/ 1000.;  // MPa
		
	return pressure;
}


// entropy S as a function of delta and tau (density and temperature)
- (double)calculateEntropyWithTemperature:(double)temperature 
							   andDensity:(double)density;
{
	double tau;
	double entropy, phi_0_tau, phi_r_tau, phi_0, phi_r;
	
	tau   = [self calculateTauWithTemperature:temperature];
	
	phi_0     = [self calculatePhi_0WithTemperature:temperature 
										 andDensity:density]; 
	phi_r     = [self calculatePhi_rWithTemperature:temperature 
										 andDensity:density]; 
	phi_0_tau = [self calculatePhi_0_tauWithTemperature:temperature 
											 andDensity:density]; 
	phi_r_tau = [self calculatePhi_r_tauWithTemperature:temperature 
											 andDensity:density]; 

	entropy = R * (tau *(phi_0_tau + phi_r_tau) - phi_0 - phi_r);
    entropy = entropy * 1000.; // J/K/kg

	return entropy;
}


// internal energy U as a function of delta and tau (density and temperature)
- (double)calculateInternalEnergyWithTemperature:(double)temperature 
									  andDensity:(double)density;
{
	double tau;
	double internalEnergy, phi_0_tau, phi_r_tau;
	
	tau   = [self calculateTauWithTemperature:temperature];
	
	phi_0_tau = [self calculatePhi_0_tauWithTemperature:temperature 
											 andDensity:density]; 
	phi_r_tau = [self calculatePhi_r_tauWithTemperature:temperature 
											 andDensity:density]; 
	
	internalEnergy = R * temperature * tau * (phi_0_tau + phi_r_tau);
    internalEnergy = internalEnergy * 1000.; // J/kg

	return internalEnergy;
}


// enthalpy H as a function of delta and tau (density and temperature)
- (double)calculateEnthalpyWithTemperature:(double)temperature 
								andDensity:(double)density;
{
	double tau, delta;
	double enthalpy, phi_0_tau, phi_r_tau, phi_r_delta;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
	
	phi_r_delta = [self calculatePhi_r_deltaWithTemperature:temperature 
												 andDensity:density]; 
	phi_0_tau   = [self calculatePhi_0_tauWithTemperature:temperature 
											   andDensity:density]; 
	phi_r_tau   = [self calculatePhi_r_tauWithTemperature:temperature 
											   andDensity:density]; 
	
	enthalpy = R * temperature * (1. + tau * (phi_0_tau + phi_r_tau) + delta * phi_r_delta);
    enthalpy = enthalpy * 1000.; // J/kg

	return enthalpy;	
}


// calculate Helmholtz fee energy as a function of delta and tau (density and temperature)
- (double)calculateHelmholtzFreeEnergyWithTemperature:(double)temperature 
										   andDensity:(double)density;
{
	double helmholtzFreeEnergy, phi_0, phi_r;
		
	phi_0       = [self calculatePhi_0WithTemperature:temperature 
										   andDensity:density]; 
	phi_r       = [self calculatePhi_rWithTemperature:temperature 
										   andDensity:density]; 	
	
	helmholtzFreeEnergy = R * temperature * (phi_0 + phi_r);
    helmholtzFreeEnergy = helmholtzFreeEnergy * 1000.; // J/kg

	return helmholtzFreeEnergy;	
	
}


// Gibbs fee energy as a function of delta and tau (density and temperature)
- (double)calculateGibbsFreeEnergyWithTemperature:(double)temperature 
									   andDensity:(double)density;
{
	double delta;
	double gibbsFreeEnergy, phi_0, phi_r, phi_r_delta;
	
	delta = [self calculateDeltaWithDensity:density];
	
	phi_r_delta = [self calculatePhi_r_deltaWithTemperature:temperature 
												 andDensity:density]; 
	phi_0       = [self calculatePhi_0WithTemperature:temperature 
										   andDensity:density]; 
	phi_r       = [self calculatePhi_rWithTemperature:temperature 
										   andDensity:density]; 	
	
	gibbsFreeEnergy = R * temperature * (1. + phi_0 + phi_r + delta * phi_r_delta);
    gibbsFreeEnergy = gibbsFreeEnergy * 1000.; // J/kg

	return gibbsFreeEnergy;	
}


// isochoric heat capacity cV as a function of delta and tau (density and temperature)
- (double)calculateCVWithTemperature:(double)temperature 
						  andDensity:(double)density;
{
	double tau;
	double cV, phi_0_tau_tau, phi_r_tau_tau;
	
	tau   = [self calculateTauWithTemperature:temperature];
	
	phi_0_tau_tau = [self calculatePhi_0_tau_tauWithTemperature:temperature 
													 andDensity:density];
	phi_r_tau_tau = [self calculatePhi_r_tau_tauWithTemperature:temperature 
													 andDensity:density]; 
	
	cV = - R * tau * tau * (phi_0_tau_tau + phi_r_tau_tau);
    cV = cV * 1000.; // J/K/kg

	return cV;	
}


// isobaric heat capacity cP as a function of delta and tau (density and temperature)
- (double)calculateCPWithTemperature:(double)temperature 
						  andDensity:(double)density;
{
	double tau, delta;
	double cP, phi_0_tau_tau, phi_r_tau_tau, phi_r_delta, phi_r_delta_tau, phi_r_delta_delta;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
	
	phi_0_tau_tau     = [self calculatePhi_0_tau_tauWithTemperature:temperature 
														 andDensity:density];
	phi_r_tau_tau     = [self calculatePhi_r_tau_tauWithTemperature:temperature 
														 andDensity:density]; 
	phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:density];
	phi_r_delta_tau   = [self calculatePhi_r_delta_tauWithTemperature:temperature 
														   andDensity:density]; 
	phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature 
															 andDensity:density]; 

	
	cP = R * ( - tau * tau * (phi_0_tau_tau + phi_r_tau_tau) + (1. + delta * phi_r_delta - delta * tau * phi_r_delta_tau) 
															 * (1. + delta * phi_r_delta - delta * tau * phi_r_delta_tau)
			                                                 /(1. + 2. * delta * phi_r_delta + delta*delta * phi_r_delta_delta));
    cP = cP * 1000.; // J/K/kg

	return cP;	
}


// calculate ideal isobaric heat capacity cPIdeal as a function of delta and tau (density and temperature)
- (double)calculateCPIdealWithTemperature:(double)temperature 
							   andDensity:(double)density;
{
	double tau;
	double cPIdeal, phi_0_tau_tau;
	
	tau   = [self calculateTauWithTemperature:temperature];
	
	phi_0_tau_tau     = [self calculatePhi_0_tau_tauWithTemperature:temperature 
														 andDensity:density];	
	
	cPIdeal = - tau * tau * R * phi_0_tau_tau + R;
    cPIdeal = cPIdeal * 1000.; // J/K/kg

	return cPIdeal;	
	
}


// speed of sound W as a function of delta and tau (density and temperature)
- (double)calculateSpeedOfSoundWithTemperature:(double)temperature 
									andDensity:(double)density;
{
	double tau, delta;
	double speedOfSound, phi_0_tau_tau, phi_r_tau_tau, phi_r_delta, phi_r_delta_tau, phi_r_delta_delta;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
	
	phi_0_tau_tau     = [self calculatePhi_0_tau_tauWithTemperature:temperature 
														 andDensity:density];
	phi_r_tau_tau     = [self calculatePhi_r_tau_tauWithTemperature:temperature 
														 andDensity:density]; 
	phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:density];
	phi_r_delta_tau   = [self calculatePhi_r_delta_tauWithTemperature:temperature 
														   andDensity:density]; 
	phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature 
															 andDensity:density]; 
	
	speedOfSound = sqrt(R * temperature * (1. + 2. * delta * phi_r_delta + delta*delta * phi_r_delta_delta 
										   - (1. + delta * phi_r_delta - delta * tau * phi_r_delta_tau) 
										   * (1. + delta * phi_r_delta - delta * tau * phi_r_delta_tau)
										   / (tau*tau * (phi_0_tau_tau + phi_r_tau_tau)) ) );
    speedOfSound = speedOfSound * sqrt(1000.); // m/s

	return speedOfSound;
}


// Joule-Thompson coefficient as a function of delta and tau (density and temperature), needs (dT/dP) at constant enthalpy
- (double)calculateJoule_ThompsonCoefficientWithTemperature:(double)temperature 
												 andDensity:(double)density;
{
	double tau, delta;
	double Joule_ThompsonCoefficient, phi_0_tau_tau, phi_r_tau_tau, phi_r_delta, phi_r_delta_tau, phi_r_delta_delta;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
 
	phi_0_tau_tau     = [self calculatePhi_0_tau_tauWithTemperature:temperature 
														 andDensity:density];
	phi_r_tau_tau     = [self calculatePhi_r_tau_tauWithTemperature:temperature 
														 andDensity:density]; 
	phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:density];
	phi_r_delta_tau   = [self calculatePhi_r_delta_tauWithTemperature:temperature 
														   andDensity:density]; 
	phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature 
															 andDensity:density]; 	
	
	Joule_ThompsonCoefficient = -1./(R*density) * (delta*phi_r_delta + pow(delta, 2.)*phi_r_delta_delta + delta*tau*phi_r_delta_tau)
												/ (pow(1. + delta*phi_r_delta - delta*tau*phi_r_delta_tau, 2.) 
                                                 - pow(tau, 2.)*(phi_0_tau_tau + phi_r_tau_tau)*(1. + 2.*delta*phi_r_delta + pow(delta, 2.)*phi_r_delta_delta));
    Joule_ThompsonCoefficient = Joule_ThompsonCoefficient * 1000.; // K/MPa

	return Joule_ThompsonCoefficient;
}


// isothermal throttling coefficient as a function of delta and tau (density and temperature), needs (dH/dP) at constant T
- (double)calculateIsothermalThrottlingCoefficientWithTemperature:(double)temperature 
													   andDensity:(double)density;
{
	double tau, delta;
	double isothermalThrottlingCoefficient, phi_r_delta, phi_r_delta_tau, phi_r_delta_delta;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];

	phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:density];
	phi_r_delta_tau   = [self calculatePhi_r_delta_tauWithTemperature:temperature 
														   andDensity:density]; 
	phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature 
															 andDensity:density]; 	
	
	isothermalThrottlingCoefficient = 1./density * ( 1. - (1. + delta*phi_r_delta - delta*tau*phi_r_delta_tau)
													    / (1. + 2.*delta*phi_r_delta + delta*delta*phi_r_delta_delta) ); // J/MPa/kg
	
	return isothermalThrottlingCoefficient;	
}


// isentropic temperature-pressure coefficient as a function of delta and tau (density and temperature), needs (dT/dP) at constant entropy
- (double)calculateIsentropicTemperaturePressureCoefficientWithTemperature:(double)temperature 
																andDensity:(double)density;
{
	double tau, delta;
	double isentropicTemperaturePressureCoefficient, phi_0_tau_tau, phi_r_tau_tau, phi_r_delta, phi_r_delta_tau, phi_r_delta_delta;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
	
	phi_0_tau_tau     = [self calculatePhi_0_tau_tauWithTemperature:temperature 
														 andDensity:density];
	phi_r_tau_tau     = [self calculatePhi_r_tau_tauWithTemperature:temperature 
														 andDensity:density]; 
	phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:density];
	phi_r_delta_tau   = [self calculatePhi_r_delta_tauWithTemperature:temperature 
														   andDensity:density]; 
	phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature 
															 andDensity:density]; 	
	
	isentropicTemperaturePressureCoefficient = 1./(R*density) * (1. + delta*phi_r_delta - delta*tau*phi_r_delta_tau) 
															  / (pow(1. + delta*phi_r_delta - delta*tau*phi_r_delta_tau, 2.) 
															   - pow(tau, 2.)*(phi_0_tau_tau + phi_r_tau_tau)*(1. + 2.*delta*phi_r_delta + pow(delta, 2.)*phi_r_delta_delta));
    isentropicTemperaturePressureCoefficient = isentropicTemperaturePressureCoefficient * 1000.; // K/MPa

	return isentropicTemperaturePressureCoefficient;		
}


// second virial coefficient as a function of tau (temperature), limit at rho -> 0
- (double)calculateSecondVirialCoefficientWithTemperature:(double)temperature;
{
	double rho;
	double secondVirialCoefficient, phi_r_delta;
	
	rho = 1.e-14;
		
	phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:rho];
	
	secondVirialCoefficient = phi_r_delta / rhoc; // m^3/kg
	
	return secondVirialCoefficient;
}


// third virial coefficient as a function of tau (temperature), limit at rho -> 0
- (double)calculateThirdVirialCoefficientWithTemperature:(double)temperature;
{
	double rho;
	double thirdVirialCoefficient, phi_r_delta_delta;
	
	rho = 1.e-14;
	
	phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature 
															 andDensity:rho]; 	
	
	thirdVirialCoefficient = phi_r_delta_delta / (rhoc * rhoc); // m^6/kg^2

	return thirdVirialCoefficient;
}


// calculate Z
- (double)calculateZWithTemperature:(double)temperature
						andPressure:(double)pressure 
						 andDensity:(double)density;
{
	double Z;
	
	Z = pressure / (density * temperature * R) * 1000.; // none
	
	return Z;
}


// calculate Fugacity
- (double)calculateFugacityWithTemperature:(double)temperature 
								andPressure:(double)pressure 
								 andDensity:(double)density;
{
	double fugacity, Z, phi_r;
		
	phi_r = [self calculatePhi_rWithTemperature:(double)temperature 
										andDensity:(double)density];
	
	Z = pressure / (density * temperature * R) * 1000.;
	
	fugacity = exp(phi_r + Z - 1. - log(Z)) * pressure; // MPa
	
	return fugacity;
}

// calculate Fugacity Coefficient
- (double)calculateFugacityCoefficientWithTemperature:(double)temperature 
										  andPressure:(double)pressure 
										   andDensity:(double)density;
{
	double fugacityCoefficient, Z, phi_r;
		
	phi_r = [self calculatePhi_rWithTemperature:(double)temperature 
									 andDensity:(double)density];
	
	Z = pressure / (density * temperature * R) * 1000.;
	
	fugacityCoefficient = exp(phi_r + Z - 1. - log(Z)); // none
	
	return fugacityCoefficient;
}


// calculate isobaric expansion coefficient alpha
- (double)calculateIsobaricExpansionCoefficientWithTemperature:(double)temperature 
													andDensity:(double)density;
{
	double tau, delta;
	double expansion, phi_r_delta, phi_r_delta_tau, phi_r_delta_delta;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
	
	phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:density];
	phi_r_delta_tau   = [self calculatePhi_r_delta_tauWithTemperature:temperature 
														   andDensity:density]; 
	phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature 
															 andDensity:density]; 
	
	expansion = 1./temperature * (1. +    delta * phi_r_delta - delta*tau *   phi_r_delta_tau) / 
							     (1. + 2.*delta * phi_r_delta + delta*delta * phi_r_delta_delta); // 1/K
	
	return expansion;
}

// calculate isothermal compressibilty beta
- (double)calculateIsothermalCompressibiltyWithTemperature:(double)temperature 
												andDensity:(double)density;
{
	double delta;
	double compressibilty, phi_r_delta, phi_r_delta_delta;
	
	delta = [self calculateDeltaWithDensity:density];
	
	phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:density];
	phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature 
															 andDensity:density]; 
	
	compressibilty = 1./(density * temperature * R) * 1. / (1. + 2.*delta * phi_r_delta  + delta*delta * phi_r_delta_delta);
    compressibilty = compressibilty * 1000.; // 1/MPa

	return compressibilty;
}

// calculate relative pressure coefficient alphaP
- (double)calculateRelativePressureCoefficientWithTemperature:(double)temperature 
												  andPressure:(double)pressure
												   andDensity:(double)density;
{
	double tau, delta;
	double alphaP, phi_r_delta, phi_r_delta_tau;
	
	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
	
	phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:density];
	phi_r_delta_tau   = [self calculatePhi_r_delta_tauWithTemperature:temperature 
														   andDensity:density]; 
	
	alphaP = density/pressure * R * (1. + delta * phi_r_delta - delta*tau * phi_r_delta_tau);
    alphaP = alphaP / 1000.; // 1/K

	return alphaP;
}

// calculate isothermal stress coefficient betaP
- (double)calculateIsothermalStressCoefficientWithTemperature:(double)temperature 
												  andPressure:(double)pressure
												   andDensity:(double)density;
{
	double delta;
	double betaP, phi_r_delta, phi_r_delta_delta;
	
	delta = [self calculateDeltaWithDensity:density];
	
	phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:density];
	phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature 
															   andDensity:density]; 
	
	betaP = density * density * temperature/pressure * R * (1. + 2. * delta * phi_r_delta + delta*delta * phi_r_delta_delta);
    betaP = betaP / 1000.; // kg/m^3

	return betaP;
}


// calculate nearly all values
- (NSMutableDictionary *)calculateAllWithTemperature:(double)temperature 
										  andDensity:(double)density;
{	
	double entropy, internalEnergy, enthalpy, helmholtzFreeEnergy, gibbsFreeEnergy;
	double cV, cP, cPIdeal, speedOfSound, Joule_ThompsonCoefficient, isothermalThrottlingCoefficient, isentropicTemperaturePressureCoefficient;
	double secondVirialCoefficient, thirdVirialCoefficient, fugacity, fugacityCoefficient, Z;
	double expansion, compressibilty, alphaP, betaP;
	double tau;
	double delta;
	double rho;
    double pressure;
	double phi_0, phi_0_tau, phi_0_tau_tau;
	double phi_r, phi_r_delta, phi_r_delta_delta, phi_r_tau, phi_r_tau_tau, phi_r_delta_tau;

	tau   = [self calculateTauWithTemperature:temperature];
	delta = [self calculateDeltaWithDensity:density];
	
		
	// calculate phi's
	phi_0             = [self calculatePhi_0WithTemperature:temperature 
												 andDensity:density];
	phi_0_tau         = [self calculatePhi_0_tauWithTemperature:temperature 
													 andDensity:density];
	phi_0_tau_tau     = [self calculatePhi_0_tau_tauWithTemperature:temperature 
														 andDensity:density];
	
	phi_r             = [self calculatePhi_rWithTemperature:temperature 
												 andDensity:density];
	phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:density];
	phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature 
															 andDensity:density];
	phi_r_tau         = [self calculatePhi_r_tauWithTemperature:temperature 
													 andDensity:density];
	phi_r_tau_tau     = [self calculatePhi_r_tau_tauWithTemperature:temperature 
														 andDensity:density];
	phi_r_delta_tau   = [self calculatePhi_r_delta_tauWithTemperature:temperature 
														   andDensity:density];
	// calculate values
    pressure                                 = density * R * temperature * (1. + delta * phi_r_delta);
	entropy                                  = R * (tau *(phi_0_tau + phi_r_tau) - phi_0 - phi_r);
	internalEnergy                           = R * temperature * tau * (phi_0_tau + phi_r_tau);
	enthalpy                                 = R * temperature * (1. + tau * (phi_0_tau + phi_r_tau) + delta * phi_r_delta);
	helmholtzFreeEnergy                      = R * temperature * (phi_0 + phi_r);
	gibbsFreeEnergy                          = R * temperature * (1. + phi_0 + phi_r + delta * phi_r_delta);
	cV                                       = - R * tau * tau * (phi_0_tau_tau + phi_r_tau_tau);
	cP                                       = R * ( - tau * tau * (phi_0_tau_tau + phi_r_tau_tau) + (1. + delta * phi_r_delta - delta * tau * phi_r_delta_tau) 
												 * (1. + delta * phi_r_delta - delta * tau * phi_r_delta_tau)
												/ (1. + 2. * delta * phi_r_delta + delta*delta * phi_r_delta_delta));
	cPIdeal                                  = - tau * tau * R * phi_0_tau_tau + R;
	speedOfSound                             = sqrt(R * temperature * (1. + 2. * delta * phi_r_delta + delta*delta * phi_r_delta_delta 
						 	                      - (1. + delta * phi_r_delta - delta * tau * phi_r_delta_tau) 
							                      * (1. + delta * phi_r_delta - delta * tau * phi_r_delta_tau)
							                      / (tau*tau * (phi_0_tau_tau + phi_r_tau_tau)) ) );
	Joule_ThompsonCoefficient                = -1./(R*density) * (delta*phi_r_delta + pow(delta, 2.)*phi_r_delta_delta + delta*tau*phi_r_delta_tau)
									               / (pow(1. + delta*phi_r_delta - delta*tau*phi_r_delta_tau, 2.) 
									               - pow(tau, 2.)*(phi_0_tau_tau + phi_r_tau_tau)*(1. + 2.*delta*phi_r_delta + pow(delta, 2.)*phi_r_delta_delta));
	isothermalThrottlingCoefficient          = 1./density * ( 1. - (1. + delta*phi_r_delta - delta*tau*phi_r_delta_tau)
												          / (1. + 2.*delta*phi_r_delta + delta*delta*phi_r_delta_delta) );
	isentropicTemperaturePressureCoefficient = 1./(R*density) * (1. + delta*phi_r_delta - delta*tau*phi_r_delta_tau) 
														      / (pow(1. + delta*phi_r_delta - delta*tau*phi_r_delta_tau, 2.) 
												              - pow(tau, 2.)*(phi_0_tau_tau + phi_r_tau_tau)*(1. + 2.*delta*phi_r_delta + pow(delta, 2.)*phi_r_delta_delta));
	expansion                                = 1./temperature * (1. +    delta * phi_r_delta - delta*tau *   phi_r_delta_tau) / 
																(1. + 2.*delta * phi_r_delta + delta*delta * phi_r_delta_delta);
	compressibilty                           = 1./(density * temperature * R) * 1. / (1. + 2.*delta * phi_r_delta  + delta*delta * phi_r_delta_delta);
	alphaP                                   = density/pressure * R * (1. + delta * phi_r_delta - delta*tau * phi_r_delta_tau);
	betaP                                    = density * density * temperature/pressure * R * (1. + 2. * delta * phi_r_delta + delta*delta * phi_r_delta_delta);
	 

	
	// Z, fugacity, fugacityCoefficient
	Z                       = pressure / (density * temperature * R);
	fugacity                = exp(phi_r + Z - 1. - log(Z)) * pressure;
	fugacityCoefficient     = exp(phi_r + Z - 1. - log(Z));
	
	// virial coefficients
	rho = 1.e-14;
	phi_r_delta             = [self calculatePhi_r_deltaWithTemperature:temperature 
													   andDensity:rho];
	phi_r_delta_delta       = [self calculatePhi_r_delta_deltaWithTemperature:temperature 
															 andDensity:rho]; 	
	secondVirialCoefficient = phi_r_delta / rhoc;
	thirdVirialCoefficient  = phi_r_delta_delta / (rhoc * rhoc);

	// dictionary
	NSMutableDictionary *values = [NSMutableDictionary dictionary];
	
	// set values in dictionary (J)
    [values setObject:[NSNumber numberWithDouble:temperature] forKey:@"t"];                                         // K
    [values setObject:[NSNumber numberWithDouble:density] forKey:@"rho"];                                           // kg/m^3
    [values setObject:[NSNumber numberWithDouble:1./density] forKey:@"v"];                                          // m^3/kg
    [values setObject:[NSNumber numberWithDouble:pressure/1000.] forKey:@"p"];                                      // MPa
	[values setObject:[NSNumber numberWithDouble:internalEnergy*1000.] forKey:@"u"];                                // J/kg
	[values setObject:[NSNumber numberWithDouble:entropy*1000.] forKey:@"s"];                                       // J/K/kg
	[values setObject:[NSNumber numberWithDouble:enthalpy*1000.] forKey:@"h"];                                      // J/kg
	[values setObject:[NSNumber numberWithDouble:helmholtzFreeEnergy*1000.] forKey:@"f"];                           // J/kg
	[values setObject:[NSNumber numberWithDouble:gibbsFreeEnergy*1000.] forKey:@"g"];                               // J/kg
	[values setObject:[NSNumber numberWithDouble:cV*1000.] forKey:@"cV"];                                           // J/K/kg
	[values setObject:[NSNumber numberWithDouble:cP*1000.] forKey:@"cP"];                                           // J/K/kg
	[values setObject:[NSNumber numberWithDouble:cPIdeal*1000.] forKey:@"cPideal"];                                 // J/K/kg
	[values setObject:[NSNumber numberWithDouble:speedOfSound*sqrt(1000.)] forKey:@"w"];                            // m/s
	[values setObject:[NSNumber numberWithDouble:Joule_ThompsonCoefficient*1000.] forKey:@"mu"];                    // K/MPa
	[values setObject:[NSNumber numberWithDouble:isothermalThrottlingCoefficient] forKey:@"deltaT"];                // J/MPa/kg
	[values setObject:[NSNumber numberWithDouble:isentropicTemperaturePressureCoefficient*1000.] forKey:@"betaS"];  // K/MPa
	[values setObject:[NSNumber numberWithDouble:Z] forKey:@"z"];                                                   // none
	[values setObject:[NSNumber numberWithDouble:fugacity/1000.] forKey:@"fug"];                                    // MPa
	[values setObject:[NSNumber numberWithDouble:fugacityCoefficient] forKey:@"phi"];                               // none
	[values setObject:[NSNumber numberWithDouble:expansion] forKey:@"alpha"];                                       // 1/K
	[values setObject:[NSNumber numberWithDouble:compressibilty*1000.] forKey:@"beta"];                             // 1/MPa
	[values setObject:[NSNumber numberWithDouble:alphaP] forKey:@"alphaP"];                                         // 1/K
	[values setObject:[NSNumber numberWithDouble:betaP] forKey:@"betaP"];                                           // kg/m^3
	[values setObject:[NSNumber numberWithDouble:secondVirialCoefficient] forKey:@"virialB"];                       // m^3/kg
	[values setObject:[NSNumber numberWithDouble:thirdVirialCoefficient] forKey:@"virialC"];                        // m^6/kg^2
	
	return values;
}


// calculate selected  values
- (id)calculatePropertiesFor:(NSString *)property
             withTemperature:(double)temperature
                 andPressure:(double)pressure
                  andDensity:(double)density;
{
    double result;
    
    if ( [property isEqualToString:@"all" ]) {
        return [self calculateAllWithTemperature:(double)temperature 
                                      andDensity:(double)density];
    }
    
    if ( [property isEqualToString:@"p" ]) {
        result = [self calculatePressureWithTemperature:(double)temperature 
                                             andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }
    
    if ( [property isEqualToString:@"rho" ]) {
        result = [self rhoWithTemperature:temperature 
                              andPressure:pressure];
        
        return [NSNumber numberWithDouble:result];
    }
    
    if ( [property isEqualToString:@"v" ]) {
        result = [self rhoWithTemperature:temperature 
                              andPressure:pressure];

        return [NSNumber numberWithDouble:1/result];
    }

    if ( [property isEqualToString:@"u" ]) {
        result =  [self calculateInternalEnergyWithTemperature:(double)temperature 
                                                    andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }
    
    if ( [property isEqualToString:@"s" ]) {
        result = [self calculateEntropyWithTemperature:(double)temperature 
                                            andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"h" ]) {
        result = [self calculateEnthalpyWithTemperature:(double)temperature 
                                             andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"f" ]) {
        result = [self calculateHelmholtzFreeEnergyWithTemperature:(double)temperature 
                                                        andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"g" ]) {
        result = [self calculateGibbsFreeEnergyWithTemperature:(double)temperature 
                                                    andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"cV" ]) {
        result = [self calculateCVWithTemperature:(double)temperature 
                                       andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"cP" ]) {
        result = [self calculateCPWithTemperature:(double)temperature 
                                       andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"cPideal" ]) {
        result = [self calculateCPIdealWithTemperature:(double)temperature 
                                            andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"w" ]) {
        result = [self calculateSpeedOfSoundWithTemperature:(double)temperature 
                                                 andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"mu" ]) {
        result = [self calculateJoule_ThompsonCoefficientWithTemperature:(double)temperature 
                                                              andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"deltaT" ]) {
        result = [self calculateIsothermalThrottlingCoefficientWithTemperature:(double)temperature 
                                                                    andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"betaS" ]) {
        result = [self calculateIsentropicTemperaturePressureCoefficientWithTemperature:(double)temperature 
                                                                             andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"z" ]) {
        result = [self calculateZWithTemperature:(double)temperature
                                     andPressure:(double)pressure 
                                      andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"fug" ]) {
        result = [self calculateFugacityWithTemperature:(double)temperature 
                                            andPressure:(double)pressure 
                                             andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"phi" ]) {
        result = [self calculateFugacityCoefficientWithTemperature:(double)temperature 
                                                       andPressure:(double)pressure 
                                                        andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"alpha" ]) {
        result = [self calculateIsobaricExpansionCoefficientWithTemperature:(double)temperature 
                                                                 andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"beta" ]) {
        result = [self calculateIsothermalCompressibiltyWithTemperature:(double)temperature 
                                                             andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"alphaP" ]) {
        result = [self calculateRelativePressureCoefficientWithTemperature:(double)temperature 
                                                               andPressure:(double)pressure
                                                                andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }
    
    if ( [property isEqualToString:@"betaP" ]) {
        result = [self calculateIsothermalStressCoefficientWithTemperature:(double)temperature 
                                                               andPressure:(double)pressure
                                                                andDensity:(double)density];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"virialB" ]) {
        result = [self calculateSecondVirialCoefficientWithTemperature:(double)temperature];
        
        return [NSNumber numberWithDouble:result];
    }

    if ( [property isEqualToString:@"virialC" ]) {
        result = [self calculateThirdVirialCoefficientWithTemperature:(double)temperature];
        
        return [NSNumber numberWithDouble:result];
    }
    
    NSLog(@"some error in calculation a property");
    
    return nil;
}


#pragma mark -
#pragma mark Additional functions

// calculate liquid density at the liquid-vapor curve
- (double)liquidDensityAtSaturation:(double)temperature;
{
	double theta, bSL[7], rhoLiquid;
	
	// calculate provisional rhoLiquid
	bSL[1] =   1.99274064;
	bSL[2] =   1.09965342;
	bSL[3] =  -0.510839303;
	bSL[4] =  -1.75493479;
	bSL[5] = -45.5170352;
	bSL[6] =  -6.74694450e5;
	
	theta    = 1. - temperature/Tc;
	rhoLiquid = rhoc *( 1. + bSL[1]*pow(theta, 1./3.) 
						   + bSL[2]*pow(theta, 2./3.) 
						   + bSL[3]*pow(theta, 5./3.) 
						   + bSL[4]*pow(theta, 16./3.) 
						   + bSL[5]*pow(theta, 43./3.) 
						   + bSL[6]*pow(theta, 110./3.) );

	return rhoLiquid;
}


// calculate vapor density at the liquid-vapor curve
- (double)vaporDensityAtSaturation:(double)temperature;
{
	double theta, cSV[7], rhoVapor;
	
	// calculate provisional rhoLiquid
	cSV[1] =  -2.03150240;
	cSV[2] =  -2.68302940;
	cSV[3] =  -5.38626492;
	cSV[4] = -17.2991605;
	cSV[5] = -44.7586581;
	cSV[6] = -63.9201063;
	
	theta    = 1. - temperature/Tc;
	rhoVapor = rhoc * exp( cSV[1]*pow(theta, 2./6.) 
                         + cSV[2]*pow(theta, 4./6.) 
                         + cSV[3]*pow(theta, 8./6.) 
                         + cSV[4]*pow(theta, 18./6.) 
                         + cSV[5]*pow(theta, 37./6.) 
                         + cSV[6]*pow(theta, 71./6.) );
	
	return rhoVapor;
}


// calculate pressure at the liquid-vapor curve
- (double)pressureVapourLiquidWithTemperature:(double)temperature;
{
	double theta, aLV[7], pLV;
	
	aLV[1] =  -7.85951783;
	aLV[2] =   1.84408259;
	aLV[3] = -11.7866497;
	aLV[4] =  22.6807411;
	aLV[5] = -15.9618719;
	aLV[6] =   1.80122502;
	
	theta = 1. - temperature/Tc;
	
	pLV = Pc*exp( Tc/temperature * ( aLV[1]*theta + aLV[2]*pow(theta,1.5) + aLV[3]*pow(theta,3.) 
												+ aLV[4]*pow(theta,3.5) + aLV[5]*pow(theta,4.) + aLV[6]*pow(theta,7.5) ) );
	
	return pLV;
}


- (double)temperatureVapourLiquidWithPressure:(double)pressure
{
	count = 0;
	
	double min = 273;
	double max = 647.05;
	
	return [self findSideWithPressure:pressure/1000.
								  min:min
								  max:max];
}


- (double)findSideWithPressure:(double)pressure min:(double)min max:(double)max
{
	count++;
	
	pressure = pressure*pow(10, 6);
	
	double middle = (min+max)/2;
	
	double minP = [self pressureVapourLiquidWithTemperature:min]*pow(10, 6);
	double middleP = [self pressureVapourLiquidWithTemperature:middle]*pow(10, 6);
	double maxP = [self pressureVapourLiquidWithTemperature:max]*pow(10, 6);
	
	NSAssert(!(pressure < minP), @"Pressure too small");
	NSAssert(!(pressure > maxP), @"Pressure too large");
	
	if ((int)pressure == (int)minP) {
		NSLog(@"%d",count);
		return min;
	}
	
	if ((int)pressure == (int)maxP) {
		NSLog(@"%d",count);
		return max;
	}
	
	if ((int)pressure == (int)middleP) {
		NSLog(@"%d",count);
		return middle;
	}
	
	if (pressure > minP && pressure < middleP) {
		return [self findSideWithPressure:pressure/pow(10, 6)
									  min:min
									  max:middle];
	} else if (pressure > middleP && pressure < maxP) {
		return [self findSideWithPressure:pressure/pow(10, 6)
									  min:middle
									  max:max];
	}
	
	return -1;
}


// calculate rho for pressure and temperature
- (double)rhoWithTemperature:(double)temperature 
				 andPressure:(double)pressure;
{
    // if pressure is zero
    // if (pressure < 1.e-100) return 1.e+100;        

	double rho, oldRho, rhoMin, logRho, rhoMax, logRhoIncrement;
	double fRho, oldfRho;
	double signfRho;
	double newRho;
	
	NSMutableArray *arrayOfRho;
	NSMutableArray *arrayOfError;
	
	arrayOfRho   = [NSMutableArray array];
	arrayOfError = [NSMutableArray array];
	
	int i;
	int unsigned long lengthArrayOfRho;
    
	// Calculate on a molar basis with Rm = 8.314472
	
	// Calculate rhoMin
    rhoMin = pressure / (2. * (coVolume * pressure + R/1000. * temperature));
    
    // Calculate rhoMax
    rhoMax = extrapolationMaxDensity;
    
    // Set rhoIncrement
    logRhoIncrement = (log(rhoMax) - log(rhoMin)) / 200.;
    
	// set logRho
	logRho = log(rhoMin);
    
	// set old rho and oldfRho
	oldRho  = rhoMin;
	oldfRho = rhoMin/1000.*R*temperature * (1. + rhoMin/rhoc*[self calculatePhi_r_deltaWithTemperature:temperature 
                                                                                            andDensity:rhoMin]) - pressure;
    
	// search roots
	i = 0;
	while (logRho < log(rhoMax)) {
		
		// increment
		i = i + 1;
		
		// new density
		logRho = logRho + logRhoIncrement;
		rho = exp(logRho);
		
		// set fRho
		fRho = rho/1000.*R*temperature * (1. + rho/rhoc*[self calculatePhi_r_deltaWithTemperature:temperature 
                                                                                       andDensity:rho]) - pressure;
        
		// set sign
		signfRho = oldfRho*fRho;
		
		// sign is negative
		if (signfRho < 0.) {
			newRho = [self findRhoWithTemperature:temperature 
									  andPressure:pressure 
							   andDensityEstimate:(oldRho+rho)/2.];
			
			// debugging
			if ([debug isEqualToString:@"debug"]) {
				NSLog(@"newRho: %18.16f, error: %@", newRho, error);
			}
			
			// add to array
			[arrayOfRho   addObject:[NSNumber numberWithDouble:newRho]];
			[arrayOfError addObject:error];
			
		}
		
		// set old values
		oldfRho = fRho;
		oldRho  = rho;
		
	}
	
    
	// debugging
    if ([debug isEqualToString:@"debug"]) {
		// print all rhos
		NSLog(@"%lu",[arrayOfRho count]);
		for(i = 0; i <= [arrayOfRho count] - 1; i = i + 1){
			NSLog(@"rho: %18.14f, error: %@",[[arrayOfRho objectAtIndex:i] doubleValue], [arrayOfError objectAtIndex:i]);
		}
	}
	
	// find correct rho
	rho = 0.;
    
    // Count arrayOfRho
	lengthArrayOfRho = [arrayOfRho count];
    
	// if there is only 1 root,this is the solution
	if (lengthArrayOfRho == 1) {
		
        rho   = [[arrayOfRho objectAtIndex:0] doubleValue];
        
        return rho;
	
    }        
    
    // above critical point
    if (temperature > Tc && pressure >= Pc) {
        
        rho   = [[arrayOfRho lastObject] doubleValue];
        
        return rho;

    }
        
    // temperature above, pressure below the critical point
    if (temperature > Tc && pressure <= Pc) {
        
        rho   = [[arrayOfRho lastObject] doubleValue];
        
        return rho;

    }

    
    // Calculate accurate saturation pressure
    double pSat = [[[self accuratePressureVapourLiquidWithTemperature:temperature] objectAtIndex:0.] doubleValue];
        
    
    // temperature above, pressure below the vapor-liquid pressure
    if (temperature <= Tc && pressure >= pSat) {
        
		rho   = [[arrayOfRho lastObject] doubleValue];
        
        return rho;
        
    }

    // temperature below, pressure above the vapor-liquid pressure
	if (temperature <= Tc && pressure < pSat) {
        
		rho = [[arrayOfRho objectAtIndex:0] doubleValue];
        
        return rho;

	}

    // Return rho (obsolete hopefully)
	return rho;
	
}


// find precise rho
- (double)findRhoWithTemperature:(double)temperature 
					 andPressure:(double)pressure 
			  andDensityEstimate:(double)density;
{
	double rho, delta, dDelta;
	double fRho, dfRho;
	double iterationGoal;
	int maxIteration, i;
	
	NSString *outerror;
    
	// set rho
	rho = density;
    
	// specific values
	iterationGoal = 1.e-12;
	maxIteration = 1000;
    
	// define delta
	delta    = rho/rhoc;
	
	// first values
	fRho  = rhoc/1000.*R*temperature * (delta + pow(delta,2.)*[self calculatePhi_r_deltaWithTemperature:temperature andDensity:rho]) - pressure;
	dfRho = rhoc/1000.*R*temperature * (   1. + 2.*delta*[self calculatePhi_r_deltaWithTemperature:temperature andDensity:rho]
										+ pow(delta,2.)*[self calculatePhi_r_delta_deltaWithTemperature:temperature andDensity:rho]);
	
	// new delta
	dDelta = -fRho/dfRho;
	delta  = delta + dDelta;
	
	// new rho
	rho   = delta*rhoc;
	
	// iteration
	i = 1;
    
	while (i <= maxIteration && fabs(dDelta) > iterationGoal) {
		        
		// calculate fRho and dfRoh
		fRho  = rhoc/1000.*R*temperature * (delta + pow(delta,2.)*[self calculatePhi_r_deltaWithTemperature:temperature andDensity:rho]) - pressure;
		dfRho = rhoc/1000.*R*temperature * (   1. + 2.*delta*[self calculatePhi_r_deltaWithTemperature:temperature andDensity:rho]
                                            + pow(delta,2.)*[self calculatePhi_r_delta_deltaWithTemperature:temperature andDensity:rho]);
        
		// new delta
		dDelta = -fRho/dfRho;
		delta  = delta + dDelta;
        
		// new rho
		rho    = delta*rhoc;
		
		// next iteration
		i = i + 1;
        
	}
	    
	// generate error message if needed
	if (i > maxIteration) {
        
		outerror = [NSString stringWithFormat:@"%@: did not reach root with the required accuracy of %e at rho: %18.16f (g/mol) after %i iterations.", fluidMethod, iterationGoal, rho, maxIteration];
		[error setString:outerror];
		
		NSLog(@"%@",error);
	}
		
    
	return rho;
}


// Calculate accurate liquid-density curve
- (NSArray *)accuratePressureVapourLiquidWithTemperature:(double)temperature
{
    // Define variables
    double pPreliminary, rhoLiquidPreliminary, rhoVaporPreliminary;
    double pressure, rhoLiquid, rhoVapor;
    
    // Calculate preliminary values for pPreliminary, rhoLiquidPreliminary and rhoVaporPreliminary
    pPreliminary         = [self pressureVapourLiquidWithTemperature:temperature];
    rhoLiquidPreliminary = [self liquidDensityAtSaturation:temperature];
    rhoVaporPreliminary  = [self vaporDensityAtSaturation:temperature];
    
    // Define Goals
    double deltaPGoal         = pPreliminary        /(1.e+9);
    double deltaRhoLiquidGoal = rhoLiquidPreliminary/(1.e+9);
    double deltaRhoVaporGoal  = rhoVaporPreliminary /(1.e+9);
    
    
    // Additinal variable definitions
    double pNew, rhoNew;
    double f, df, deltaRho, deltaP = 1.e+99;
    
    double delta, phi_r_delta, phi_r_delta_delta;
    
    // Counter
    NSInteger j = 0;
    
    // For Pressure
    while ( deltaP > deltaPGoal && j < 1000 ) {
        
        // Increase counter
        j = j + 1;
        
        // Iterate liquid density
        // Counter
        NSInteger i = 0;
        deltaRho =  1.e+99;
        
        while ( deltaRho > deltaRhoLiquidGoal && i < 10000)  {
            
            // Increase counter
            i = i + 1;
            
            // Calculate f and df
            f  = [self calculatePressureWithTemperature:temperature andDensity:rhoLiquidPreliminary] - pPreliminary;
            
            delta             = [self calculateDeltaWithDensity:rhoLiquidPreliminary];
            phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature
                                                               andDensity:rhoLiquidPreliminary];
            phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature
                                                                     andDensity:rhoLiquidPreliminary];
            
            df = R * temperature * ( 1. + 2. * delta * phi_r_delta + delta * delta * phi_r_delta_delta ) / 1000.;
            
            // Calculate rhoNew
            rhoNew = rhoLiquidPreliminary - f/df/2.;
            
            // Calculate deltaRho
            deltaRho = fabs(rhoLiquidPreliminary - rhoNew);
            
            // Assign new rhoLiquidPreliminary
            rhoLiquidPreliminary = rhoNew;
            
        }
        
        // Iterate vapor density
        // Counter
        i = 0;
        deltaRho = 1.e+99;
        
        while ( deltaRho > deltaRhoVaporGoal && i < 10000)  {
            
            // Increase counter
            i = i + 1;
            
            // Calculate f and df
            f  = [self calculatePressureWithTemperature:temperature andDensity:rhoVaporPreliminary] - pPreliminary;
            
            delta             = [self calculateDeltaWithDensity:rhoVaporPreliminary];
            phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:temperature
                                                               andDensity:rhoVaporPreliminary];
            phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:temperature
                                                                     andDensity:rhoVaporPreliminary];
            
            df = R * temperature * ( 1. + 2. * delta * phi_r_delta + delta * delta * phi_r_delta_delta ) / 1000.;
            
            // Calculate rhoNew
            rhoNew = rhoVaporPreliminary - f/df/2.;
            
            // Calculate deltaRho
            deltaRho = fabs(rhoVaporPreliminary - rhoNew);
            
            // Assign new rhoLiquidPreliminary
            rhoVaporPreliminary = rhoNew;
            
        }
        
        // Calculatate new pNew
        pNew = - ( [self calculateHelmholtzFreeEnergyWithTemperature:temperature andDensity:rhoLiquidPreliminary] - [self calculateHelmholtzFreeEnergyWithTemperature:temperature andDensity:rhoVaporPreliminary] ) /
        ( 1./rhoLiquidPreliminary - 1./rhoVaporPreliminary );
        pNew = pNew / 1.e+6;
        
        // Calculate deltaP
        deltaP = fabs(pPreliminary - pNew);
        
        // Assign new pPreliminary
        pPreliminary = pNew;
        
    }
    
    pressure  = pPreliminary;
    rhoLiquid = rhoLiquidPreliminary;
    rhoVapor  = rhoVaporPreliminary;
    
    // Pack result
    NSArray *result = [NSArray arrayWithObjects:[NSNumber numberWithDouble:pressure],
                       [NSNumber numberWithDouble:rhoLiquid],
                       [NSNumber numberWithDouble:rhoVapor],
                       nil];
    
    // Return result
    return result;
    
}


// calculate accurate temperature at the liuid-vapor curve
- (NSArray *)accurateTemperatureVapourLiquidWithPressure:(double)pressure
{
    // Define variables
    double tPreliminary, rhoLiquidPreliminary, rhoVaporPreliminary;
    double rhoLiquid, rhoVapor;
    
    // Calculate preliminary values for tPreliminary
    double deltaT = 1.e-12;
    double f, df, dx = 1.e+99;
    
    // Counter
    NSInteger i = 0;
    
    // Calculate preliminary values for tPreliminary, rhoLiquidPreliminary and rhoVaporPreliminary
    tPreliminary = (regularMinTemperature + Tc) / 2.;
    
    while (fabs(dx) > 1.e-5 && i < 1000 ) {
        
        // Set increment
        f  =  [self pressureVapourLiquidWithTemperature:tPreliminary] - pressure;
        df = ([self pressureVapourLiquidWithTemperature:tPreliminary + deltaT] - [self pressureVapourLiquidWithTemperature:tPreliminary - deltaT]) / (2. * deltaT);
        dx =  - f / df/2.;
        
        // Calculate tPreliminary
        tPreliminary = tPreliminary + dx;
        if (tPreliminary > Tc)   tPreliminary = Tc   - 1.e-9;
        if (tPreliminary < regularMinTemperature) tPreliminary = regularMinTemperature + 1.e-9;
        
        i = i + 1;
        
    }
    
    // Calculate preliminary values for rhoLiquidPreliminary and rhoVaporPreliminary
    rhoLiquidPreliminary = [self liquidDensityAtSaturation:tPreliminary];
    rhoVaporPreliminary  = [self vaporDensityAtSaturation:tPreliminary];
    
    // Define Goals
    double deltaTGoal         = tPreliminary        /(1.e+8);
    double deltaRhoLiquidGoal = rhoLiquidPreliminary/(1.e+9);
    double deltaRhoVaporGoal  = rhoVaporPreliminary /(1.e+9);
    
    
    
    // Additinal variable definitions
    double tNew, rhoNew;
    
    double delta, phi_r_delta, phi_r_delta_delta;
    
    // Counter
    NSInteger j = 0;
    deltaT =  1.e+99;
    
    // For Pressure
    while ( deltaT > deltaTGoal && j < 100 ) {
        
        // Increase counter
        j = j + 1;
        
        // Iterate liquid density
        // Counter
        NSInteger i = 0;
        double deltaRho =  1.e+99;
        
        while ( deltaRho > deltaRhoLiquidGoal && i < 10000)  {
            
            // Increase counter
            i = i + 1;
            
            // Calculate f and df
            f  = [self calculatePressureWithTemperature:tPreliminary andDensity:rhoLiquidPreliminary] - pressure;
            
            delta             = [self calculateDeltaWithDensity:rhoLiquidPreliminary];
            phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:tPreliminary
                                                               andDensity:rhoLiquidPreliminary];
            phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:tPreliminary
                                                                     andDensity:rhoLiquidPreliminary];
            
            df = R * tPreliminary * ( 1. + 2. * delta * phi_r_delta + delta * delta * phi_r_delta_delta ) / 1000.;
            
            // Calculate rhoNew
            rhoNew = rhoLiquidPreliminary - f/df/2.;
            
            // Calculate deltaRho
            deltaRho = fabs(rhoLiquidPreliminary - rhoNew);
            
            // Assign new rhoLiquidPreliminary
            rhoLiquidPreliminary = rhoNew;
            
        }
        
        
        // Iterate vapor density
        // Counter
        i = 0;
        deltaRho = 1.e+99;
        
        while ( deltaRho > deltaRhoVaporGoal && i < 10000)  {
            
            // Increase counter
            i = i + 1;
            
            // Calculate f and df
            f  = [self calculatePressureWithTemperature:tPreliminary andDensity:rhoVaporPreliminary] - pressure;
            
            delta             = [self calculateDeltaWithDensity:rhoVaporPreliminary];
            phi_r_delta       = [self calculatePhi_r_deltaWithTemperature:tPreliminary
                                                               andDensity:rhoVaporPreliminary];
            phi_r_delta_delta = [self calculatePhi_r_delta_deltaWithTemperature:tPreliminary
                                                                     andDensity:rhoVaporPreliminary];
            
            df = R * tPreliminary * ( 1. + 2. * delta * phi_r_delta + delta * delta * phi_r_delta_delta ) / 1000.;
            
            // Calculate rhoNew
            rhoNew = rhoVaporPreliminary - f/df/2.;
            
            // Calculate deltaRho
            deltaRho = fabs(rhoVaporPreliminary - rhoNew);
            
            // Assign new rhoLiquidPreliminary
            rhoVaporPreliminary = rhoNew;
            
        }
        
        
        // Iterate vapor temperature
        // Counter
        i = 0;
        double deltaTTemp = 1.e+99;
        double tNewTemp, tPreliminaryTemp;
        
        // Store tPreliminaryTemp
        tPreliminaryTemp = tPreliminary;
        
        while (deltaTTemp > deltaTGoal && i < 10000) {
            
            // Increase counter
            i = i + 1;
            
            // Calculate f and df
            f  =   [self calculateHelmholtzFreeEnergyWithTemperature:tPreliminaryTemp andDensity:rhoLiquidPreliminary] - [self calculateHelmholtzFreeEnergyWithTemperature:tPreliminaryTemp andDensity:rhoVaporPreliminary]
            + pressure * 1.e+6 * (1./rhoLiquidPreliminary - 1./rhoVaporPreliminary);
            
            df = - [self calculateEntropyWithTemperature:tPreliminaryTemp andDensity:rhoLiquidPreliminary] + [self calculateEntropyWithTemperature:tPreliminaryTemp andDensity:rhoVaporPreliminary];
            
            // Calculatate new tNewTemp
            tNewTemp =  tPreliminaryTemp - f/df/2.;
            
            // Calculate deltaTTemp
            deltaTTemp = fabs(tPreliminaryTemp - tNewTemp);
            
            // Assign new tPreliminaryTemp
            tPreliminaryTemp = tNewTemp;
            
        }
        
        // Calculatate new tNew
        tNew = tPreliminaryTemp;
        
        // Calculate deltaT
        deltaT = fabs(tPreliminary - tNew);
        
        // Assign new tPreliminary
        tPreliminary = tNew;
        
    }
    
    double temperature;
    
    // Results
    rhoLiquid = rhoLiquidPreliminary;
    rhoVapor  = rhoVaporPreliminary;
    temperature = tPreliminary;
    
    // Pack result
    NSArray *result = [NSArray arrayWithObjects:[NSNumber numberWithDouble:temperature],
                       [NSNumber numberWithDouble:rhoLiquid],
                       [NSNumber numberWithDouble:rhoVapor],
                       nil];
    
    // Return result
    return result;
    
}

@end
