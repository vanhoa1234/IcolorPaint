
#include "CloneStamp.h"


CCloneStamp::CCloneStamp(void)
{
    searchWindowRate = 0.5;
}

CCloneStamp::CCloneStamp(float areaRate)
{
    searchWindowRate = areaRate;
}

CCloneStamp::~CCloneStamp(void)
{
}

void CCloneStamp::expandRect(cv::Rect &rect, const float expandRat, const cv::Size boundary)
{
    float x = (float)(rect.width*expandRat);
    float y = (float)(rect.height*expandRat);
    rect.x = MAX(rect.x-x/2.0, 0);
    rect.y = MAX(rect.y-y/2.0, 0);
    rect.width = MIN(rect.width + x, boundary.width-rect.x);
    rect.height = MIN(rect.height + y, boundary.height-rect.y);
}

void CCloneStamp::fillExemplar(const cv::Mat &originalImg, const cv::Mat &mask, cv::Mat &destImg)
{
//    double oldTime = (double)cv::getTickCount();
    cv::Mat cntImg= mask.clone();
    destImg = originalImg.clone();
    std::vector<std::vector<cv::Point>> cnt;
    cv::findContours(cntImg, cnt, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    for (size_t i=0; i<cnt.size(); i++)
    {
        cv::Rect rect = cv::boundingRect(cv::Mat(cnt[i]));
        
        bool objSmall = false;
        int objSize = MIN(rect.width, rect.height);
        if (objSize < INPAINT_THIN)
            objSmall = true;
        
        expandRect(rect, searchWindowRate, originalImg.size());
        cv::Mat src = originalImg(rect).clone();
        cv::Mat m =  mask(rect).clone();
        
        
        if (objSmall){
            inpaintSmallObject(src, m, objSize);
            src.copyTo(destImg(rect), mask(rect));
        } else {        
            
            Inpainter ipter(src, m);
            if(ipter.checkValidInputs()==ipter.CHECK_VALID)
            {
                ipter.inpaint();
                ipter.result.clone().copyTo(destImg(rect));
            }
        }
    }
    cntImg.release();
    cnt.clear();
    
//    double currentTime = (double)cv::getTickCount();
//    std::cout << "Inpaint total time = "  << (currentTime - oldTime)/cv::getTickFrequency() << std::endl;
}

void CCloneStamp::inpaintCV(const cv::Mat &originalImg, const cv::Mat &mask, cv::Mat &destImg)
{
    cv::inpaint(originalImg, mask, destImg, 10, cv::INPAINT_TELEA);
}


void CCloneStamp::prepareSourceImageWithDirection(cv::Mat &src, const cv::Mat &mask, const cv::Rect &orgRect, int direction){

	cv::Rect r;
	switch (direction) {
	case DIRECTION_TOP_TO_BOTTOM:
		r = cv::Rect(0, mask.rows - orgRect.height/2, orgRect.width, orgRect.height/2);
		break;
	case DIRECTION_BOTTOM_TO_TOP:
		r = cv::Rect(0, 0, orgRect.width, orgRect.height/2);
		break;
	case DIRECTION_LEFT_TO_RIGHT:
		r = cv::Rect(mask.cols - orgRect.width/2, 0, orgRect.width/2, orgRect.height);
		break;            
	case DIRECTION_RIGHT_TO_LEFT:      
		r = cv::Rect(0, 0, orgRect.width/2, orgRect.height);
		break;
	default:
		break;
	}

	cv::Mat s = src(r);
	cv::Mat m1 = mask(r).clone();
	cv::bitwise_not(mask, m1);
	cv::Mat s1 = s.clone();
	s1.setTo(0);
	s1.copyTo(s, m1);
}

int _dir;

int CCloneStamp::expandRectWithDirection(cv::Rect &rect, const float expandRat, const cv::Size boundary, cv::Point pt)
{
   
    int direction = _dir;
  
	int windowSize = -3;
    float x = (float)(rect.width*expandRat);
    float y = (float)(rect.height*expandRat);
    int left = MAX(rect.x-x-windowSize, 0);
    int top = MAX(rect.y-y-windowSize, 0);
    int width = MIN(rect.width + x + 2*windowSize, boundary.width-left);
    int height = MIN(rect.height + y + 2*windowSize, boundary.height-top);
    
    switch (direction) {
        case DIRECTION_TOP_TO_BOTTOM:
            rect.y = top;
            rect.height = height;
            break;
        case DIRECTION_BOTTOM_TO_TOP:
			rect.y = MAX(rect.y-windowSize, 0);
            rect.height = height;
            break;
        case DIRECTION_LEFT_TO_RIGHT:
            rect.x = left;
            rect.width = width;
            break;            
        case DIRECTION_RIGHT_TO_LEFT:
			rect.x = MAX(rect.x-windowSize, 0);
            rect.width = width;
			break;
        default:
            rect.y += 7;
            rect.height += 14;
            rect.x += 7;
            rect.width += 14;
            break;
    }
    
	return direction;
}

void drawLine(const cv::Mat &mask, cv::Point2f &pt1, cv::Point2f &pt2){
	std::vector<cv::Point> points;
	cv::Vec4f lines;
	points.push_back(pt1);
	points.push_back(pt2);
	cv::fitLine(cv::Mat(points), lines, 2, 0, 0.001, 0.001);
	int lefty = (-lines[2]*lines[1]/lines[0])+lines[3];
	int righty = ((mask.cols-lines[2])*lines[1]/lines[0])+lines[3];
	pt1 = cv::Point(mask.cols-1,righty);
	pt2 = cv::Point(0,lefty);
}

/**
 * Rotate an image
 */
cv::Mat CCloneStamp::rotate(const cv::Mat &src, const cv::Mat &r/*double angle, cv::Point2f centerPoint*/, cv::Mat& dst)
{
/*	cv::Point2f pt(centerPoint);
	if (centerPoint.x <= 0)
		pt = cv::Point2f(src.cols/2., src.rows/2.);
    cv::Mat r = cv::getRotationMatrix2D(pt, angle, 1.0);
*/	
	cv::warpAffine(src, dst, r, src.size(), cv::INTER_LANCZOS4+CV_WARP_FILL_OUTLIERS, cv::BORDER_REPLICATE);
	return r;
}

/**
 * Rotate an image
 */
cv::Mat CCloneStamp::rotate(const cv::Mat &src, double angle, cv::Point2f centerPoint, cv::Mat& dst)
{
	cv::Point2f pt(centerPoint);
	if (centerPoint.x <= 0)
		pt = cv::Point2f(src.cols/2., src.rows/2.);
    cv::Mat r = cv::getRotationMatrix2D(pt, angle, 1.0);
	cv::warpAffine(src, dst, r, src.size(), cv::INTER_LANCZOS4+CV_WARP_FILL_OUTLIERS, cv::BORDER_REPLICATE);
	return r;
}

bool CCloneStamp::correctRect(cv::Rect &rect, const cv::Mat &img)
{
	bool correct = false;
	if (rect.x<0){
		rect.width += rect.x;
		rect.x = 0;
		correct = true;
	}
	if ((rect.x+rect.width)>=img.cols){
		rect.width = img.cols-rect.x-1;
		correct = true;
	}

	if (rect.y<0){
		rect.height += rect.y;
		rect.y = 0;
		correct = true;
	}
	if ((rect.y+rect.height)>=img.rows){
		rect.height = img.rows - rect.y -1;
		correct = true;
	}
	return correct;
}

void CCloneStamp::waitKey(){
	std::cout << "Press any key to continue ..." << std::endl;
	cv::waitKey();
	std::cout << "Processing ..." << std::endl;
}

cv::Rect CCloneStamp::getRotatedRect(cv::Point2f pts[], const cv::Mat &rotMat)
{
	std::vector<cv::Point2f> points;
	for (int i = 0; i < 4; i++){
		cv::Point2f pt;
		pt.x = rotMat.at<double>(0,0)*pts[i].x + rotMat.at<double>(0,1)*pts[i].y + rotMat.at<double>(0,2);
		pt.y = rotMat.at<double>(1,0)*pts[i].x + rotMat.at<double>(1,1)*pts[i].y + rotMat.at<double>(1,2);
		points.push_back(pt);
	}
	cv::RotatedRect box = cv::minAreaRect(cv::Mat(points));
	return box.boundingRect();
}

cv::Point2f CCloneStamp::extentImage(const cv::Mat &src, const cv::Mat &mask, cv::RotatedRect &box, cv::Mat &dst, cv::Mat &maskDst, cv::Mat &rM){
	bool ext = false;
	double angle = box.angle;
	if (angle < -45.)	angle += 90.;

	cv::Rect r = box.boundingRect();
	cv::Size newImageSize(src.cols, src.rows);
    cv::Rect rect = r | cv::Rect(0,0,src.cols,src.rows);
    std::cout<<"rect = " << rect<< " image size = " << src.size() << std::endl;
    
	cv::Point2f pt(0, 0);
	if (rect.x<0){
		ext = true;
		newImageSize.width -= rect.x;
		pt.x = -rect.x;
	}
	if (rect.width>src.cols) {
		ext = true;
		newImageSize.width = 2*rect.width-src.cols;
	}
	if (rect.y<0){
		ext = true;
		newImageSize.height-= rect.y;
		pt.y = -rect.y;
	}
	if (rect.height>src.rows) {
		ext = true;
		newImageSize.height = 2*rect.height-src.rows;
	}

    std::cout<< "new image size = " << newImageSize << std::endl;
	
    dst = cv::Mat::zeros(newImageSize, src.type());
	maskDst = cv::Mat::zeros(newImageSize, mask.type());
	src.copyTo(dst(cv::Rect(pt.x,pt.y,src.cols,src.rows)));
	mask.copyTo(maskDst(cv::Rect(pt.x,pt.y,src.cols,src.rows)));
	rM = cv::getRotationMatrix2D(cv::Point2f(box.center+pt), angle, 1.0);
	rotate(dst, rM, dst);
	rotate(maskDst, rM, maskDst);

	return pt;
}

void blendAlpha(cv::Mat &img, const cv::Mat &mask){
    cv::Mat temp;
    if (mask.channels()==1)
        cv::cvtColor(mask, temp, cv::COLOR_GRAY2BGR);
    else
        temp = mask.clone();
    
    cv::Mat t=img.clone();
    temp.copyTo(t, mask);
    cv::add(0.5*img, 0.5*t, img);
}

void CCloneStamp::rotateImage(const cv::Mat &src, const cv::Mat &mask, const std::vector<cv::Point> &points, cv::Mat &dst, cv::Point ctrPoint)
{
	cv::RotatedRect box = cv::minAreaRect(cv::Mat(points));

	double angle = box.angle;
	if (angle < -45.){
        angle += 90.;
    }
    
    std::cout<<"Angle = " << angle<< std::endl;
    
	cv::Mat srcRot, maskRot, rM;
	cv::Mat maskWithBorder = cv::Mat::zeros(mask.size(), mask.type());
	cv::Rect w = cv::Rect(7, 7, mask.cols-14, mask.rows-14);
	mask(w).copyTo(maskWithBorder(w));
	cv::Point2f offsetPoint = extentImage(src, maskWithBorder, box, srcRot, maskRot, rM);

	cv::Point2f vertices[4];
	box.points(vertices);
	for(int i =0; i<4; i++)
		vertices[i]+=offsetPoint;
	cv::Rect rect = getRotatedRect(vertices, rM);
    
    bool objSmall = false;
    int objSize = MIN(rect.width, rect.height);
    if (objSize < INPAINT_THIN)
        objSmall = true;

    std::cout<< "Rotation image with location: " << ctrPoint <<", rect:" << rect <<std::endl;
	cv::Point2f controlPt;
	ctrPoint += cv::Point(offsetPoint.x, offsetPoint.y);
	controlPt.x = rM.at<double>(0,0)*ctrPoint.x + rM.at<double>(0,1)*ctrPoint.y + rM.at<double>(0,2);
	controlPt.y = rM.at<double>(1,0)*ctrPoint.x + rM.at<double>(1,1)*ctrPoint.y + rM.at<double>(1,2);

    std::cout<< "Control point =  " << controlPt  << "or = " << ctrPoint <<std::endl;
    
	if (rect.area() < 25) return;
	expandRectWithDirection(rect, searchWindowRate, srcRot.size(), controlPt);
	correctRect(rect, maskRot);

	cv::Mat src1 = srcRot(rect).clone();
	cv::Mat m =  maskRot(rect).clone();
    
    if (objSmall){
        inpaintSmallObject(src1, m, objSize);
        src1.copyTo(srcRot(rect), mask(rect));
    }else {
        Inpainter ipter(src1, m);
        if(ipter.checkValidInputs()==ipter.CHECK_VALID)
        {
            ipter.inpaint();
            ipter.result.clone().copyTo(srcRot(rect));
        }
    }

	rotate(srcRot, -angle, box.center+offsetPoint, srcRot);
	srcRot(cv::Rect(offsetPoint.x, offsetPoint.y, src.cols, src.rows)).copyTo(dst, mask);
    
//	std::cout << "offset = " << offsetPoint << std::endl;
//    cv::Mat a = dst(cv::Rect(dst.cols/2,100,src1.cols, src1.rows));
//    blendAlpha(a, src1);
}

double CCloneStamp::prepareSourceImageWithPointControl(cv::Mat &mask, const std::vector<cv::Point> &points, cv::Point controlPoint)
{
	mask.setTo(0);
	int lineSize = 1;
	cv::RotatedRect box = cv::minAreaRect(cv::Mat(points));

	double angle = box.angle;
	if (angle < -45.)
		angle += 90.;

	cv::Point2f vertices[4];
	box.points(vertices);
	drawLine(mask, vertices[0], vertices[2]);
	cv::line(mask, vertices[0], vertices[2], cv::Scalar(255,255,255), lineSize);	
	drawLine(mask, vertices[1], vertices[3]);
	cv::line(mask, vertices[1], vertices[3], cv::Scalar(255,255,255), lineSize);
	cv::Mat mask1 = cv::Mat::zeros(cv::Size(mask.cols+2, mask.rows+2), CV_8U);
	cv::floodFill(mask, controlPoint, cv::Scalar(255, 255, 255, 255));

//	cv::imshow("minAreaRect", mask);
//	cv::waitKey(0);

	return angle;
}

void CCloneStamp::fillExemplarWithDirection(const cv::Mat &originalImg, const cv::Mat &mask, cv::Mat &destImg, cv::Point controlPt)
{
    //    double oldTime = (double)cv::getTickCount();
    cv::Mat cntImg= mask.clone();
	cv::threshold(cntImg, cntImg, 10, 255, CV_THRESH_BINARY);
    destImg = originalImg.clone();
    std::vector<std::vector<cv::Point>> cnt;
    cv::findContours(cntImg, cnt, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    for (size_t i=0; i<cnt.size(); i++)
    {
		rotateImage(originalImg, mask, cnt[i], destImg, controlPt);
/*
        cv::Rect rect = cv::boundingRect(cv::Mat(cnt[i]));
		if (rect.area() < 25) continue;		
        cv::Rect r(rect);        
        int direction = expandRectWithDirection(rect, searchWindowRate, originalImg.size(), controlPt);
        cv::Mat src = originalImg(rect).clone();
		cv::Mat m =  mask(rect).clone();

		prepareSourceImageWithDirection(src, m, r, direction);
		Inpainter ipter(src, m);
        if(ipter.checkValidInputs()==ipter.CHECK_VALID)
        {
            ipter.inpaint();
            ipter.result.clone().copyTo(destImg(rect));
        }
*/   
	}
    cntImg.release();
    cnt.clear();
    
    //    double currentTime = (double)cv::getTickCount();
    //    std::cout << "Inpaint total time = "  << (currentTime - oldTime)/cv::getTickFrequency() << std::endl;
    
}


void CCloneStamp::inpaintSmallObject(cv::Mat &img, const cv::Mat &mask, int objMinSize){
    if (objMinSize<8){
        std::cout << "Small object is clearing ... by cv::inpaint" << std::endl;
        cv::inpaint(img, mask, img, 7, cv::INPAINT_TELEA);
    } else {
        std::cout << "Small object is clearing ... by zoom in" << std::endl;
        cv::Mat src, m;
        cv::Size zS = cv::Size(2*img.cols, 2*img.rows);
        cv::resize(img, src, zS);
        cv::resize(mask, m, zS);
        Inpainter ipter(src, m);
        if(ipter.checkValidInputs()==ipter.CHECK_VALID)
        {
            ipter.inpaint();
            ipter.result.copyTo(src);            
            cv::resize(src, img, img.size());
        }
    }
}

void CCloneStamp::fillExemplarWithNoneRotation(const cv::Mat &originalImg, const cv::Mat &mask, cv::Mat &destImg, int ctrl)
{
    cv::Mat cntImg= mask.clone();
	cv::threshold(cntImg, cntImg, 10, 255, CV_THRESH_BINARY);
    destImg = originalImg.clone();
    std::vector<std::vector<cv::Point>> cnt;
    cv::findContours(cntImg, cnt, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    
    for (size_t i=0; i<cnt.size(); i++)
    {
        cv::Rect rect = cv::boundingRect(cnt[i]);
        
        std::cout << "obj size = " << rect <<std::endl;
        bool objSmall = false;
        int objSize = MIN(rect.width, rect.height);
        if (objSize < INPAINT_THIN)
            objSmall = true;
            
        
        int windowSize = 0;
        float expandRat = searchWindowRate;
        //    std::cout << "original rect = " << rect << std::endl;
        float x = (float)(rect.width*expandRat);
        float y = (float)(rect.height*expandRat);
        int left = MAX(rect.x-x-windowSize, 0);
        int top = MAX(rect.y-y-windowSize, 0);
        int width = MIN(rect.width + x + 2*windowSize, originalImg.cols-left);
        int height = MIN(rect.height + y + 2*windowSize, originalImg.rows-top);
        
        switch (ctrl) {
            case DIRECTION_TOP_TO_BOTTOM:
                rect.y = top;
                rect.height = height;
                break;
            case DIRECTION_BOTTOM_TO_TOP:
                rect.y = MAX(rect.y-windowSize, 0);
                rect.height = height;
                break;
            case DIRECTION_LEFT_TO_RIGHT:
                rect.x = left;
                rect.width = width;
                break;
            case DIRECTION_RIGHT_TO_LEFT:
                rect.x = MAX(rect.x-windowSize, 0);
                rect.width = width;
                break;
            default:
                break;
        }
        correctRect(rect, originalImg);
        cv::Mat src1 = originalImg(rect).clone();
        cv::Mat m =  mask(rect).clone();
        
        if (objSmall){
            inpaintSmallObject(src1, m, objSize);
            src1.copyTo(destImg(rect), mask(rect));
        } else {
            Inpainter ipter(src1, m);
            if(ipter.checkValidInputs()==ipter.CHECK_VALID)
            {
                ipter.inpaint();
                ipter.result.clone().copyTo(destImg(rect), mask(rect));
            }
        }
	}
    
    cntImg.release();
    cnt.clear();
}

void CCloneStamp::fillExemplarWithDirectionControl(const cv::Mat &originalImg, const cv::Mat &mask, cv::Mat &destImg, int ctrl)
{
    cv::Mat cntImg= mask.clone();
	cv::threshold(cntImg, cntImg, 10, 255, CV_THRESH_BINARY);
    destImg = originalImg.clone();
    std::vector<std::vector<cv::Point>> cnt;
    cv::findContours(cntImg, cnt, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    
    _dir = ctrl;
    for (size_t i=0; i<cnt.size(); i++)
    {
        cv::Point pt(0,0);
        cv::Rect rect = cv::boundingRect(cnt[i]);
        
        cv::RotatedRect box = cv::minAreaRect(cv::Mat(cnt[i]));
        double angle = box.angle;
        if (angle < -45.){
            angle += 90.;
        }
        float angleThresh = 0.5;
        if ((abs(angle)<angleThresh)||(abs(angle-90)<angleThresh)||(abs(angle-180)<angleThresh)||(abs(angle+90)<angleThresh)){
            fillExemplarWithNoneRotation(originalImg, mask, destImg, ctrl);
        }else {
        
            switch(ctrl){
                case 0:
                    pt.x = rect.x+rect.width/2;
                    pt.y = rect.y-rect.height;
                    break;
                case 1:
                    pt.x = rect.x+rect.width+rect.width;
                    pt.y = rect.y+rect.height/2;
                    break;
                case 2:
                    pt.x = rect.x+rect.width/2;
                    pt.y = rect.y+rect.height+rect.height;
                    break;
                case 3:
                    pt.x = rect.x-rect.width;
                    pt.y = rect.y+rect.height/2;
                    break;
                    
            }
            rotateImage(originalImg, mask, cnt[i], destImg, pt);
        }
	}
    
    cntImg.release();
    cnt.clear();
}

void CCloneStamp::stopProccess(bool stop){
    Inpainter ipter;
    ipter.stop(stop);
}
