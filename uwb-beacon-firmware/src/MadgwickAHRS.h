// =====================================================================================================
// MadgwickAHRS.h
// =====================================================================================================
//
// Implementation of Madgwick's IMU and AHRS algorithms.
// See: http://www.x-io.co.uk/node/8#open_source_ahrs_and_imu_algorithms
//
// Date			Author          Notes
// 29/09/2011	SOH Madgwick    Initial release
// 02/10/2011	SOH Madgwick	Optimised for reduced CPU load
//
// =====================================================================================================
#ifndef MadgwickAHRS_h
#define MadgwickAHRS_h

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    float q[4];
    float beta;
    float sample_frequency;
} madgwick_filter_t;

void madgwick_filter_init(madgwick_filter_t* f);

void madgwick_filter_set_gain(madgwick_filter_t* f, float beta);
void madgwick_filter_set_sample_frequency(madgwick_filter_t* f, float freq);

void madgwick_filter_update(madgwick_filter_t* f,
                            float gx,
                            float gy,
                            float gz,
                            float ax,
                            float ay,
                            float az,
                            float mx,
                            float my,
                            float mz);
void madgwick_filter_updateIMU(madgwick_filter_t* f,
                               float gx,
                               float gy,
                               float gz,
                               float ax,
                               float ay,
                               float az);

#ifdef __cplusplus
}
#endif

#endif