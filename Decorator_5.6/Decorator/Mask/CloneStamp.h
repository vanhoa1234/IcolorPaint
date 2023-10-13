#pragma once
#include "inpainter.h"

class CCloneStamp
{
public:
    const static int INPAINT_THIN = 17;
    
    const static int DIRECTION_TOP_TO_BOTTOM=0;
    const static int DIRECTION_BOTTOM_TO_TOP=2;
    const static int DIRECTION_LEFT_TO_RIGHT=3;
    const static int DIRECTION_RIGHT_TO_LEFT=1;
    const static int DIRECTION_EXPAND=4;
    
	CCloneStamp(void);
    CCloneStamp(float areaRate);
	~CCloneStamp(void);    

    void fillExemplar(const cv::Mat &originalImg, const cv::Mat &mask, cv::Mat &destImg);
    void inpaintCV(const cv::Mat &originalImg, const cv::Mat &mask, cv::Mat &destImg);
    void fillExemplarWithDirection(const cv::Mat &originalImg, const cv::Mat &mask, cv::Mat &destImg, cv::Point controlPt);
    void fillExemplarWithDirectionControl(const cv::Mat &originalImg, const cv::Mat &mask, cv::Mat &destImg, int ctrl);
    void stopProccess(bool stop);
    
private:

	cv::Rect getRotatedRect(cv::Point2f pts[], const cv::Mat &rotMat);
	bool correctRect(cv::Rect &rect, const cv::Mat &img);

	cv::Point2f extentImage(const cv::Mat &src, const cv::Mat &mask, cv::RotatedRect &box, cv::Mat &dst, cv::Mat &maskDst, cv::Mat &rM);

	cv::Mat rotate(const cv::Mat &src, const cv::Mat &r/*double angle, cv::Point2f centerPoint*/, cv::Mat& dst);
	cv::Mat rotate(const cv::Mat &src, double angle, cv::Point2f centerPoint, cv::Mat& dst);
	void rotateImage(const cv::Mat &src, const cv::Mat &mask, const std::vector<cv::Point> &points, cv::Mat &dst, cv::Point ctrPoint);
	void prepareSourceImageWithDirection(cv::Mat &src, const cv::Mat &mask,  const cv::Rect &orgRect, int direction);
	double prepareSourceImageWithPointControl(cv::Mat &mask, const std::vector<cv::Point> &points, cv::Point controlPoint);
    int expandRectWithDirection(cv::Rect &rect, const float expandRat, const cv::Size boundary, cv::Point pt);
    
    void fillExemplarWithNoneRotation(const cv::Mat &originalImg, const cv::Mat &mask, cv::Mat &destImg, int ctrl);
    void inpaintSmallObject(cv::Mat &img, const cv::Mat &mask, int objMinSize);

	void expandRect(cv::Rect &rect, const float expandRat, const cv::Size boundary);
	void waitKey();

    float searchWindowRate;
};

