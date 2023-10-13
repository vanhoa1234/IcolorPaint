//
//  Mask.cpp
//  Decorator
//
//  Created by HuanVB on 9/9/13.
//  Copyright (c) 2013 HuanVB. All rights reserved.
//

#include "Mask.h"

const int connectivity = 8;
const int newMaskVal = 255;
//const double maxHoleSizeRatio = 0.005;
//const double maxEdgeSizeRatio = 0.005;
const int tolerance = 20;
const int transparent = 0;

/// <summary>
/// Initializes a new instance of the <see cref="CMask"/> class.
/// </summary>
CMask::CMask(void)
	: m_nTolerance (tolerance)
    , m_nTransparent (transparent)
    , m_index(-1)
    , m_nonePainting(false)
    , m_bHighLight(false)
    , referenceColor(-300)
    , m_bSetRefColor(false)
{
	setColor(210, 204, 102);
	m_bDefaultColor = true;
    m_ptCurrentSeed = cv::Point(-1, -1);
#if DEVELOPMENT
	m_ptCurrent = cv::Point(0, 0);
#endif	
}

/// <summary>
/// Initializes a new instance of the <see cref="CMask"/> class.
/// </summary>
/// <param name="r">The r.</param>
/// <param name="g">The g.</param>
/// <param name="b">The b.</param>
CMask::CMask(const int r, const int g, const int b)
    : m_nTolerance (tolerance)
    , m_nTransparent (transparent)
    , m_index(-1)
    , m_nonePainting(false)
    , m_bHighLight(false)
    , referenceColor(-300)
    , m_bSetRefColor(false)
{
	setColor(r, g, b);
    m_ptCurrentSeed = cv::Point(-1, -1);
	m_bDefaultColor = true;
#if DEVELOPMENT
	m_ptCurrent = cv::Point(0, 0);
#endif
}

/// <summary>
/// Finalizes an instance of the <see cref="CMask"/> class.
/// </summary>
CMask::~CMask(void)
{
	for(int i=0; i<m_imgMaskList.size(); i++)
		m_imgMaskList[i].release();
	m_imgMaskList.clear();
	m_imgPattern.release();
    m_imgDst.release();
}

/// <summary>
/// Sets the color.
/// </summary>
/// <param name="r">The r.</param>
/// <param name="g">The g.</param>
/// <param name="b">The b.</param>
void CMask::setColor(int r, int g, int b)
{
	cv::Mat color(1, 1, CV_8UC3, CV_RGB(b, g, r));
	cv::cvtColor(color, color, CV_BGR2HSV);
	m_scColor = (cv::Scalar) color.at<cv::Vec3b>(0,0);
	m_imgPattern.release();
    m_imgDst.release();
    if((r==0)&&(g==0)&&(b==0))
    {
        setNonePainting(true);
    }
	m_bDefaultColor = false;
}

/// <summary>
/// Sets the color.
/// </summary>
/// <param name="imgPattern">The img pattern.</param>
void CMask::setColor(const cv::Mat &imgPattern)
{
	cv::Mat src;
    cv::cvtColor(imgPattern, src, CV_BGRA2BGR);
    m_imgPattern = src.clone();
    m_imgDst.release();
    src.release();
}

void CMask::setDefaultColor(const bool def){
    m_bDefaultColor = def;
}

void CMask::setReferenceColor(const int color){
    m_bSetRefColor = true;
    m_bDefaultColor = false;
    referenceColor = color;
}

int CMask::getReferenceColor(){
    return referenceColor;
}

/// <summary>
/// Sets the none painting.
/// </summary>
/// <param name="np">The np.</param>
void CMask::setNonePainting(const bool np)
{
    m_nonePainting = np;
    m_imgDst.release();
}
// get mask to be non painting
bool CMask::getNonePainting(){
    return m_nonePainting;
}

void CMask::setHighLight(const bool hl){
    m_bHighLight = hl;
}

/// <summary>
/// Sets the tolerance.
/// </summary>
/// <param name="tol">The tol.</param>
void CMask::setTolerance(const int tol)
{
	m_nTolerance = tol;
//    std::cout << "Tol=" << m_nTolerance << std::endl;
}

/// <summary>
/// Sets the transparent color.
/// </summary>
/// <param name="transparent">The transparent.</param>
void CMask::setTransparent(const int transparent)
{
    m_nTransparent = transparent;
    if (m_nTransparent<0) m_nTransparent = 0;
    if (m_nTransparent>100) m_nTransparent = 100;
}

// get transparent color
int CMask::getTransparent(){
    return m_nTransparent;
}

bool CMask::iniMaskByImagePath(const std::string pathFile)
{
	cv::Mat mask = cv::imread(pathFile, CV_LOAD_IMAGE_GRAYSCALE);
    if (! mask.data) return false;
    if ((mask.cols<10) || (mask.rows < 10)) return false;
    m_imgDst.release();
    m_imgMaskList.push_back(mask);
    m_index ++;
    mask.release();
    return true;
}

const cv::Mat CMask::getCurrentMask()
{
    if (m_index<0) return cv::Mat();
    return m_imgMaskList[m_index];
}

bool CMask::findDynamicRange(const cv::Mat &imgSrc, const cv::Mat &mask, int &minValue, int &maxValue)
{
    /// Establish the number of bins
    const int histSize = 256;
    /// Set the ranges ( for B,G,R) )
    const float range[] = { 0, 256 } ;
    const float* histRange = {range};
    const bool uniform = true, accumulate = false;
    cv::Mat hist;
    /// Compute the histograms:
    cv::calcHist(&imgSrc, 1, 0, mask, hist, 1, &histSize, &histRange, uniform, accumulate);
    cv::blur(hist, hist, cv::Size(17, 17));    
    double histMaxVal;
    cv::minMaxLoc(hist, NULL, &histMaxVal, NULL, NULL);
    histMaxVal = hist.at<float>(referenceColor);
    double ratio = 0.5/100.0;
    for( int i = 0; i < histSize; i++ )
    {
        if (hist.at<float>(i)>=histMaxVal*ratio)
        {
            minValue = i;
            break;
        }
    }
    for( int i = histSize-1; i >=0; i-- )
    {
        if (hist.at<float>(i)>=histMaxVal*ratio)
        {
            maxValue = i;
            break;
        }
    }
    return true;
}

/// <summary>
/// Calculates the color in mask.
/// </summary>
/// <param name="imgSrc">The img SRC.</param>
/// <param name="mask">The mask.</param>
/// <returns>int.</returns>
int CMask::calculateColorInMask(const cv::Mat &imgSrc, const cv::Mat &mask)
{
    std::cout << "re-calculate referent color. Index = " << m_index << std::endl;
    /// Establish the number of bins
    const int histSize = 256;
    /// Set the ranges ( for B,G,R) )
    const float range[] = { 0, 256 } ;
    const float* histRange = {range};
    const bool uniform = true, accumulate = false;
    cv::Mat hist;
    /// Compute the histograms:
    cv::calcHist(&imgSrc, 1, 0, mask, hist, 1, &histSize, &histRange, uniform, accumulate);
    cv::blur(hist, hist, cv::Size(17, 17));  
    cv::Point maxLoc;
    cv::minMaxLoc(hist, NULL, NULL, NULL, &maxLoc);  
    return maxLoc.y;
}

void CMask::compressDynamicToReference(const cv::Mat &ref, cv::Mat &dest, const cv::Mat &mask)
{
    cv::Mat refGray;
    double refMinVal, refMaxVal, resultMinVal, resultMaxVal;
    cv::cvtColor(ref, refGray, CV_BGRA2GRAY);
    cv::minMaxLoc(refGray, &refMinVal, &refMaxVal, NULL, NULL);
    cv::minMaxLoc(dest, &resultMinVal, &resultMaxVal, NULL, NULL, mask);
    if ((resultMinVal<refMinVal) && (resultMaxVal>refMaxVal)) return;
//    std::cout << "(refMinVal, refMaxVal) = (" << refMinVal <<", " << refMaxVal << ")"<< std::endl;
//    std::cout << "(resultMinVal, resultMaxVal) = (" << resultMinVal <<", " << resultMaxVal << ")"<< std::endl;
    if(resultMaxVal == resultMinVal) resultMaxVal++;
    double alpha, beta;
    alpha = (refMaxVal - refMinVal)/(resultMaxVal - resultMinVal);
    beta = refMinVal-resultMinVal*alpha;
    dest.convertTo(refGray, CV_8U, alpha, beta);
    refGray.copyTo(dest, mask);
//    cv::minMaxLoc(dest, &resultMinVal, &resultMaxVal, NULL, NULL, mask);
//    std::cout << "(resultMinVal, resultMaxVal) = (" << resultMinVal <<", " << resultMaxVal << ")"<< std::endl;
    refGray.release();
}

/// <summary>
/// Draws the pattern.
/// </summary>
/// <param name="imgDst">The img DST.</param>
/// <param name="pattern">The pattern.</param>
/// <param name="mask">The mask.</param>
void CMask::drawPattern(const cv::Mat &imgSrc, cv::Mat &imgDst, const cv::Mat &pattern, const cv::Mat &mask)
{
	if ((!imgDst.data) || (!mask.data) || (imgDst.size()!=mask.size())) return;
    if ((pattern.rows>mask.rows)||(pattern.cols>mask.cols)) return;
    for (int i = 0; i < imgDst.rows; i += pattern.rows)
	{
		for (int j = 0; j < imgDst.cols; j += pattern.cols)
        {
            cv::Rect rect = cv::Rect(j, i, pattern.cols, pattern.rows) 
				& cv::Rect(0, 0, imgDst.cols, imgDst.rows);
            cv::Mat sub_dst(imgDst, rect);
            cv::Mat sub_mask(mask, rect);
			pattern(cv::Rect(0, 0, rect.width, rect.height)).copyTo(sub_dst, sub_mask);
        }
	}
    
    cv::Mat srcBGR, hsv, blur, texture;
    
    cv::GaussianBlur(imgDst, blur, cv::Size(11, 11), 0);
    texture = imgDst - blur;
    
    cv::cvtColor(imgSrc, srcBGR, CV_BGRA2GRAY);
    cv::cvtColor(imgDst, hsv, CV_BGR2HSV);
    
    cv::Mat planes[] = {cv::Mat::zeros(imgSrc.size(), CV_8UC1),
        cv::Mat::zeros(imgSrc.size(), CV_8UC1),  cv::Mat::zeros(imgSrc.size(), CV_8UC1)};
    cv::split(hsv, planes);
    
    cv::add((0.5-m_nTransparent/200.0)*srcBGR, (0.5+m_nTransparent/200.0)*planes[2], planes[2], mask);
    compressDynamicToReference(pattern, planes[2], mask);
    
    cv::merge(planes, 3, hsv);
    cv::cvtColor(hsv, imgDst, CV_HSV2BGR);
    cv::add((0.5-m_nTransparent/200.0)*texture, imgDst, imgDst, mask);
    
    cv::cvtColor(imgDst, hsv, CV_BGR2HSV);
    cv::split(hsv, planes);
    compressDynamicToReference(pattern, planes[2], mask);
    cv::merge(planes, 3, hsv);
    cv::cvtColor(hsv, imgDst, CV_HSV2BGR);
    
    srcBGR.release();
    blur.release();
    texture.release();
    hsv.release();
    planes[0].release();
    planes[1].release();
    planes[2].release();
}

void CMask::compressDynamicRange(cv::Mat &image, const int replace, const int reference, const cv::Mat &mask)
{
    int minVal, maxVal;
    findDynamicRange(image, mask, minVal, maxVal);
    double plus = replace-reference;
    double rangeLeft = (double)(replace/(replace - (minVal+plus)+1.0));
    double rangeRight = (double)((256.0-replace)/(maxVal + plus - replace+1.0));
    
    int lookUp[256];
    int range = 256;
    std::cout << "Transparent: " << m_nTransparent << std::endl;
    int min = m_nTransparent*reference/100.0;
    int max = 256 - (256-reference)*m_nTransparent/100.0;
    for (int i = 0; i< range; i++)
    {
        double val = i*(max-min)/256+min+plus;
        if ((minVal+plus)<0)
        {
            if (val<replace)
            {
                val = (val-minVal-plus)*rangeLeft;
            }
        }
        else if ((maxVal+plus)>255)
        {
            if (val>replace)
            {
                val = (val-replace)*rangeRight+replace;
            }
        }
        
        if (val<0) lookUp[i] = 0;
        else if (val>255) lookUp[i] =255;
        else lookUp[i] = val;
    }    
 
    for (int rowIndex = 0; rowIndex < image.rows; rowIndex++)
    for (int colIndex = 0; colIndex < image.cols; colIndex++)
    {
        if (((cv::Scalar)mask.at<uchar>(rowIndex, colIndex)).val[0]>0)
        {
            int gray = ((cv::Scalar)image.at<uchar>(rowIndex, colIndex)).val[0];
            image.at<uchar>(rowIndex, colIndex)= lookUp[gray];
        }  
    }
    
/*
//    image += plus;
    if ((minVal+plus)<0)
    {
        std::cout << "minVal+plus = " << minVal+plus << std::endl;
        //plus = -minVal;
        image.convertTo(image, CV_8U, (maxVal+plus)/(maxVal - minVal),-minVal*(maxVal+plus)/(maxVal-minVal));
    }
    else if ((maxVal+plus)>255)
    {
        std::cout << "maxVal+plus = " << maxVal+plus << std::endl;
        //plus = (255-maxVal);
        image.convertTo(image, CV_8U, (255-minVal-plus)/(maxVal - minVal), 255-maxVal*(255-minVal-plus)/(maxVal-minVal));
    }
    else
    {
        std::cout << "plus color = " << plus << std::endl;
        image += plus;
    }
 */   //cv::minMaxLoc(image, &minVal, &maxVal, NULL, NULL, mask);
    //std::cout << "ref minVal = " << minVal << " maxValue = " << maxVal << std::endl;
}

/// <summary>
/// Replaces the color.
/// </summary>
/// <param name="imgSrc">The img SRC.</param>
/// <param name="imgDst">The img DST.</param>
/// <param name="newColor">The new color.</param>
/// <param name="mask">The mask.</param>
void CMask::replaceColor(const cv::Mat &imgSrc, cv::Mat &imgDst, const cv::Scalar newColor, const cv::Mat &mask)
{
	if ((!imgSrc.data) || (!imgDst.data) || (!mask.data) 
		|| (imgSrc.size()!=imgDst.size()) || (imgSrc.size()!=mask.size())) return;

	cv::Mat hsvImage;
    cv::cvtColor(imgSrc, hsvImage, CV_BGRA2BGR);
	cv::cvtColor(hsvImage, hsvImage, CV_BGR2HSV);
	cv::Mat planes[] = {cv::Mat::zeros(imgSrc.size(), CV_8UC1), 
		cv::Mat::zeros(imgSrc.size(), CV_8UC1),  cv::Mat::zeros(imgSrc.size(), CV_8UC1)};

	cv::split(hsvImage, planes);

	cv::Mat temp = cv::Mat::zeros(imgSrc.size(), CV_8UC2);
	cv::merge(planes, 2, temp);
	temp.setTo(newColor, mask);

	cv::Mat planes2[] = {cv::Mat::zeros(imgSrc.size(), CV_8UC1), cv::Mat::zeros(imgSrc.size(), CV_8UC1)};
	cv::split(temp, planes2);
	planes2[0].copyTo(planes[0]);
	planes2[1].copyTo(planes[1]);
    
//	if (!m_bDefaultColor){
		if (referenceColor == -300){
			referenceColor = calculateColorInMask(planes[2], mask);
		}
		else if (m_index>0){
			if(cv::countNonZero(m_imgMaskList[m_index-1].clone())==0){
				referenceColor = calculateColorInMask(planes[2], mask);
			}
		}
//	}
    
    int grayValue = referenceColor;
	if (m_bDefaultColor)
        grayValue = 127;
//    std::cout << "replaced color = " << grayValue << std::endl;
//    std::cout << "painted color = "<< newColor.val[2] << std::endl;
    compressDynamicRange(planes[2], newColor.val[2], grayValue, mask);

    
    cv::Mat dst;
	cv::merge(planes, 3, dst);
	cv::cvtColor(dst, dst, CV_HSV2BGR);
    dst.copyTo(imgDst, mask);
    
    hsvImage.release();
    temp.release();
    dst.release();
    planes[0].release();
    planes[1].release();
    planes[2].release();
    planes2[0].release();
    planes2[1].release();
}

/// <summary>
/// Paints the specified img SRC.
/// </summary>
/// <param name="imgSrc">The img SRC.</param>
/// <param name="imgDst">The img DST.</param>
void CMask::Paint(const cv::Mat &imgSrc, cv::Mat &imgDst)
{
	if (!imgSrc.data) return;
 
    if (!imgDst.data)
	{
        cv::Mat src;
        cv::cvtColor(imgSrc, src, CV_BGRA2BGR);
        imgDst = src.clone();
        src.release();
	}
    
    if ((m_index<0)||(m_index>m_imgMaskList.size()-1)) return;

    cv::Mat m = m_imgMaskList[m_index].clone();

    if (imgSrc.size()!=m.size())
    {
        cv::resize(m, m, imgSrc.size());
        //	cv::dilate(m, m, cv::Mat());
    }


 /*   for(int i=1; i<=m_index; i++)
    {
        m_imgMaskList[i].copyTo(m, m_imgMaskList[i]);
    }
 */
    // copy cached image to showing
    if (m_imgDst.data){
        m_imgDst.copyTo(imgDst, m);
        highLight(m, imgDst);
        return;
    }
    
    if (m_nonePainting)
    {
        cv::Mat src;
        cv::cvtColor(imgSrc, src, CV_BGRA2BGR);
        src.copyTo(imgDst, m);
        src.release();
    }
    else
    {
		if(!m_imgPattern.data)
			replaceColor(imgSrc, imgDst, m_scColor, m);
		else
			drawPattern(imgSrc, imgDst, m_imgPattern, m);

/*
        replaceColor(imgSrc, imgDst, m_scColor, m);
        if(m_imgPattern.data)
            drawPattern(imgSrc, imgDst, m_imgPattern, m);
 */
    }
    m_imgDst = imgDst.clone();
    
    highLight(m, imgDst);
    
    
#if DEVELOPMENT
	cv::circle(imgDst, m_ptCurrent, 10, CV_RGB(255,0,0), 5);
#endif    
    m.release();
}

void CMask::highLight(const cv::Mat &mask, cv::Mat &imgDst){
    if(m_bHighLight){
        std::vector<std::vector<cv::Point>> cnt;
        cv::findContours(mask, cnt, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
        cv::drawContours(imgDst, cnt, -1, CV_RGB(255, 255, 255), 3);
        cv::drawContours(imgDst, cnt, -1, CV_RGB(0, 0, 0));
        cnt.clear();
    }
}

void CMask::getHighLightRegion(std::vector<std::vector<cv::Point>> &region){
    
    if ((m_index<0)||(m_index>m_imgMaskList.size()-1)) return;
    cv::Mat m = m_imgMaskList[m_index].clone();
    cv::findContours(m, region, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    m.release();
}

void CMask::drawHighLight(cv::Mat &dst){
    std::vector<std::vector<cv::Point>> cnt;
    getHighLightRegion(cnt);
    cv::drawContours(dst, cnt, -1, CV_RGB(255, 255, 255), 3);
    cv::drawContours(dst, cnt, -1, CV_RGB(0, 0, 0));
    cnt.clear();
}

/// <summary>
/// Removes the small edge.
/// </summary>
/// <param name="edge">The edge.</param>
void CMask::removeSmallEdge(cv::Mat &edge)
{
    if (!edge.data) return;
    cv::Mat cnt_img = edge.clone();
    const double areaThreshold = 200;//edge.rows*edge.cols*maxEdgeSizeRatio;
    std::vector<std::vector<cv::Point>> cnt;
    cv::findContours(cnt_img, cnt, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    for (size_t i=0; i<cnt.size(); i++)
    {
        double area = cv::arcLength(cv::Mat(cnt[i]), false);//fabs(cv::contourArea(cv::Mat(cnt[i])));
        if (area < areaThreshold)
        {
            cv::floodFill(edge, cnt[i][0], CV_RGB(0, 0, 0), NULL, cv::Scalar(0), cv::Scalar(0), 8|cv::FLOODFILL_FIXED_RANGE);
            //cv::drawContours(edge, cnt, i, CV_RGB(0, 0, 0), CV_FILLED);
        }
    }
    cnt_img.release();
    cnt.clear();    
}

void CMask::calculateEdge(const cv::Mat &imgSrc, cv::Mat &edge)
{
	cv::Canny(imgSrc, edge, 50, 50);    
    cv::Mat kernel = cv::Mat::ones(3, 3, CV_8U);
    cv::dilate(edge, edge, kernel);
    cv::Mat eroded;
    cv::erode(edge, eroded, kernel);
    edge = edge - eroded;
//#if CMASK_RESIZE
    cv::pyrDown(edge, edge);
    cv::dilate(edge, edge, kernel);
//#endif
    kernel.release();
    eroded.release();
}

void CMask::removeEdgeOnSeedPoint(cv::Mat &edge, const cv::Point seedPt)
{
	if (edge.at<unsigned char>(seedPt)>0)
    {
        cv::floodFill(edge, seedPt, CV_RGB(0, 0, 0), NULL, cv::Scalar(0), cv::Scalar(0), 
			8|cv::FLOODFILL_FIXED_RANGE);
    }
}

void CMask::limiteMaskUsingEdge(const cv::Mat &imgSrc, cv::Mat &mask, const cv::Point seedPt)
{
	if (!imgSrc.data) return;
	cv::Mat edge;
	calculateEdge(imgSrc, edge);
	removeEdgeOnSeedPoint(edge, seedPt);
	cv::Mat mask_inv = cv::Mat::zeros(edge.size(), edge.type());
    mask_inv.copyTo(mask, edge);
	cv::Mat maskDst = cv::Mat::zeros(mask.rows+2, mask.cols+2, CV_8UC1);
	cv::floodFill(mask, maskDst, seedPt, cv::Scalar(255, 255, 255), NULL,
		cv::Scalar(0), cv::Scalar(0),  8|cv::FLOODFILL_FIXED_RANGE);
	maskDst(cv::Rect(1, 1, edge.cols, edge.rows)).copyTo(mask);
    mask_inv.release();
    edge.release();
	maskDst.release();
}

/// <summary>
/// Removes the hole.
/// </summary>
void CMask::removeHole(cv::Mat &img)
{
    cv::dilate(img, img, cv::Mat(), cv::Point(-1, -1), 3);
    cv::erode(img, img, cv::Mat(), cv::Point(-1, -1), 2);
    cv::threshold(img, img, 127, 255, CV_THRESH_BINARY);
}

/// <summary>
/// Removes the redo.
/// </summary>
void CMask::removeRedo()
{
    if (m_imgMaskList.size()>0)
    {
        for(int index=m_index+1; index < m_imgMaskList.size(); index++)
            m_imgMaskList[index].release();
        m_imgMaskList.erase(m_imgMaskList.begin()+m_index+1, m_imgMaskList.end());
    }
}

/// <summary>
/// Erases the mask.
/// </summary>
/// <param name="src">The SRC.</param>
/// <param name="dst">The DST.</param>
void CMask::eraseMask(const cv::Mat &src, cv::Mat &dst)
{
    cv::Mat mask_inv = cv::Mat::zeros(src.size(), src.type());
    mask_inv.copyTo(dst, src);
    mask_inv.release();
}

bool CMask::removeMaskedRegion(cv::Mat &mask, const cv::Mat &maskedImage)
{
    if (!mask.data) return false;
    if (!maskedImage.data) return false;
    if (mask.size()!=maskedImage.size())
    {
        std::cout << "Size of mask is not equal masked image." << std::endl;
        return false;
    }
    cv::Mat m;
    cv::bitwise_and(mask, maskedImage, m);
    cv::subtract(mask, m, mask);
    return true;
}

/// <summary>
/// Adds the mask.
/// </summary>
/// <param name="mask">The mask.</param>
/// <param name="add">The add.</param>
void CMask::addMask(const cv::Mat &mask, const bool add)
{
    m_imgDst.release();
    removeRedo();
    if (m_index<0)
    {
        m_imgMaskList.push_back(mask.clone().setTo(0));
        m_index ++;
        if (add==false)
            m_imgMaskList.push_back(mask.clone().setTo(0));
        else
            m_imgMaskList.push_back(mask);
    }
    else
    {
        cv::Mat m = m_imgMaskList[m_index].clone();
        if (add==true) {
            mask.copyTo(m, mask);
        }
        else {
            eraseMask(mask, m);
        }
        m_imgMaskList.push_back(m);
        m.release();
    }
    m_index++;
}


/// <summary>
/// Smoothes the border.
/// </summary>
/// <param name="src">The SRC.</param>
void CMask::smoothBorder(cv::Mat &src)
{
	cv::Mat cnt_img = cv::Mat::zeros(src.size(), src.type());
    std::vector<std::vector<cv::Point>> cnt;
    std::vector<std::vector<cv::Point>> approxCnt;
    cv::findContours(cnt_img, cnt, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    approxCnt.resize(cnt.size());
    for (size_t i=0; i<cnt.size(); i++)
    {
        cv::approxPolyDP(cv::Mat(cnt[i]), approxCnt[i], 3, true);
    }    
    cv::drawContours(src, approxCnt, -1, CV_RGB(255,255,255), CV_FILLED);
    cnt_img.release();
    cnt.clear();
    approxCnt.clear();
}


bool CMask::createMaskBySeed(const cv::Mat &imgSrc, const cv::Mat &imgResizedSrc, cv::Mat &maskDst, const cv::Point seedPt, const bool limitedEdge)
{
    if (!imgSrc.data) return false;
	if ((seedPt.x<0) || (seedPt.y<0) || (seedPt.x > imgResizedSrc.cols-1) || (seedPt.y > imgResizedSrc.rows-1)) return false;
#if DEVELOPMENT
	m_ptCurrent = seedPt;
    std::cout << "Seed = " << seedPt.x << ", " << seedPt.y << std::endl;
#endif
    
	cv::Mat img = imgResizedSrc;
	cv::Point seed=seedPt;
    
#if CMASK_RESIZE
    //        cv::pyrDown(imgSrc, img);
    seed = cv::Point(seedPt.x/2.0, seedPt.y/2.0);
#endif
    
	cv::Mat hsvImage;
	cv::cvtColor(img, hsvImage, CV_BGRA2BGR);// CV_BGR2HSV
    cv::GaussianBlur(hsvImage, hsvImage, cv::Size(7,7), 0.5);
	cv::Scalar newVal = cv::Scalar(255, 255, 255);
	cv::Scalar tol = cv::Scalar(m_nTolerance, m_nTolerance, m_nTolerance);
	int flags = connectivity + (newMaskVal << 8) + cv::FLOODFILL_FIXED_RANGE + cv::FLOODFILL_MASK_ONLY;
	cv::Mat mask = cv::Mat::zeros(img.rows+2, img.cols+2, CV_8UC1);
    cv::floodFill(hsvImage, mask, seed, newVal, NULL, tol, tol, flags);

    if (limitedEdge)
	{
        cv::Mat m = mask(cv::Rect(1, 1, img.cols, img.rows));
		limiteMaskUsingEdge(imgSrc, m, seed);
	}
    smoothBorder(mask);
	removeHole(mask);
    maskDst = mask(cv::Rect(1, 1, img.cols, img.rows)).clone();
    
    img.release();
    hsvImage.release();
    mask.release();
    return true;
}

/// <summary>
/// Adds the mask by seed.
/// </summary>
/// <param name="imgSrc">The img SRC.</param>
/// <param name="seedPt">The seed pt.</param>
/// <param name="limitedEdge">The limited edge.</param>
/// <returns>bool.</returns>
bool CMask::addMaskBySeed(const cv::Mat &imgSrc, const cv::Mat &imgResizedSrc, const cv::Point seedPt, const bool limitedEdge, const cv::Mat &maskedImage)
{
    cv::Mat mask;
	if (createMaskBySeed(imgSrc, imgResizedSrc, mask, seedPt, limitedEdge))
    {
        // fix bug SUZUKADECO-362
        if (m_index<=0){
            if(m_bSetRefColor){
                m_bSetRefColor = false;
            } else {
                referenceColor = -300;
            }
        }
        // 522
        removeMaskedRegion(mask, maskedImage);
        // end fix bug
        addMask(mask);
        mask.release();
        m_ptCurrentSeed = seedPt;
        return true;
    }
	return false;
}

bool CMask::modifyMask(const cv::Mat &mask)
{
    if (m_imgMaskList.size()<1) return false;
    if (m_index != m_imgMaskList.size()-1) return false;
    if (!mask.data) return false;
    
    m_imgDst.release();
    cv::Mat m = m_imgMaskList[m_index-1].clone();
    mask.copyTo(m, mask);
    m_imgMaskList[m_index] = m.clone();
    m.release();
    return true;
}

bool CMask::modifyMaskBySeed(const cv::Mat &imgSrc, const cv::Mat &imgResizedSrc, const cv::Point seedPt, const bool limitedEdge, const cv::Mat &maskedImage)
{
    if (m_imgMaskList.size()<1) return false;
    if (m_index != m_imgMaskList.size()-1) return false;
    if (m_ptCurrentSeed.x<0 && m_ptCurrentSeed.y<0) return false;
    cv::Mat mask;
    if (createMaskBySeed(imgSrc, imgResizedSrc, mask, m_ptCurrentSeed, limitedEdge))
    {
        // 522
        cv::Mat masked;
        cv::subtract(maskedImage, m_imgMaskList[m_index], masked);
        removeMaskedRegion(mask, masked);
        // end 522
        
        modifyMask(mask);
        mask.release();
        return true;
    }
    return false;
}

/// <summary>
/// Refines the polygon.
/// </summary>
/// <param name="imgSrc">The img SRC.</param>
/// <param name="polySrc">The poly SRC.</param>
/// <param name="polyDes">The poly DES.</param>
void CMask::refinePolygon(const cv::Mat &imgSrc, const std::vector<cv::Point> &polySrc, std::vector<cv::Point> &polyDes)
{
    cv::Mat img;
    cv::cvtColor(imgSrc, img, CV_BGRA2GRAY);
     std::vector<cv::Point2f> pol2f;
    for (int i = 0; i < polySrc.size(); i++)
    {
#if CMASK_RESIZE
        pol2f.push_back(cv::Point(polySrc[i].x/2.0, polySrc[i].y/2.0));
#else
        pol2f.push_back(polySrc[i]);
#endif
    }
    
    cv::Size winSize = cv::Size(7, 7);
    cv::Size zeroZone = cv::Size(-1, -1);
    cv::TermCriteria criteria = cv::TermCriteria(CV_TERMCRIT_EPS+CV_TERMCRIT_ITER, 40, 0.0001);
    cv::cornerSubPix(img, pol2f, winSize, zeroZone, criteria);
    img.release();    
    for (int i = 0; i < polySrc.size(); i++)
    {
        polyDes.push_back(pol2f[i]);
    }
}

bool CMask::creatMaskByPolygon(cv::Mat &mask, const std::vector<cv::Point> &polygon)
{
    if (!mask.data) return false;
    const int lineType = 8;
    const int pointNumbers = polygon.size();
	cv::Point* rook_points[1];
	rook_points[0] = new cv::Point[pointNumbers];
	for(int i=0; i<polygon.size(); i++)
		rook_points[0][i] = polygon[i];
	const cv::Point* ppt[1] = {rook_points[0]};
	int npt[] = {pointNumbers};
	cv::fillPoly(mask, ppt, npt, 1, CV_RGB(255, 255, 255), lineType );
    delete rook_points[0];
    return true;    
}

/// <summary>
/// Adds the mask by polygon.
/// </summary>
/// <param name="imgSrc">The img SRC.</param>
/// <param name="polygon">The polygon.</param>
/// <param name="add">The add.</param>
/// <returns>bool.</returns>
bool CMask::addMaskByPolygon(const cv::Mat &imgSrc, const std::vector<cv::Point> &polygon, const bool add)
{
	if (!imgSrc.data) return false;
    if (polygon.size()==0) return false;    
	cv::Mat img = imgSrc;
	cv::Mat mask = cv::Mat::zeros(img.size(), CV_8UC1);    
    std::vector<cv::Point> refinePoly;
    refinePolygon(img, polygon, refinePoly);    
	creatMaskByPolygon(mask, refinePoly);        
    addMask(mask, add);
    img.release();
    mask.release();
	return true;
}

bool CMask::addMaskByPoints(const cv::Mat &imgSrc, const std::vector<cv::Point> &points, const bool add, const cv::Mat &maskedImage)
{
    if (!imgSrc.data) return false;
    if (points.size()==0) return false;
    // fix bug SUZUKADECO-362
    if (m_index<=0){
        if (add==false);
//            return true; // fix reopen SUZUKADECO-306
        else {
            if(m_bSetRefColor){
                m_bSetRefColor = false;
            } else {
                referenceColor = -300;
            }
        }
    }
    // end fix bug
	cv::Mat img = imgSrc;
	cv::Mat mask = cv::Mat::zeros(img.size(), CV_8UC1);
	creatMaskByPolygon(mask, points);
    
    // fix 522
    if (add) {
        removeMaskedRegion(mask,maskedImage);
    }
    
    addMask(mask, add);
    img.release();
    mask.release();
	return true;
}

bool CMask::modifyMaskByPoints(const cv::Mat &imgSrc, const std::vector<cv::Point> &points)
{
    if (!imgSrc.data) return false;
    if (points.size()==0) return false;
	cv::Mat img = imgSrc;
	cv::Mat mask = cv::Mat::zeros(img.size(), CV_8UC1);
	creatMaskByPolygon(mask, points);
    modifyMask(mask);
    img.release();
    mask.release();
    return true;
    
}

/// <summary>
/// Erases the mask by polygon.
/// </summary>
/// <param name="imgSrc">The img SRC.</param>
/// <param name="polygon">The polygon.</param>
/// <param name="toolSize">Size of the tool.</param>
/// <returns>bool.</returns>
bool CMask::eraseMaskByPolygon(const cv::Mat &imgSrc, const std::vector<cv::Point> &polygon, const int toolSize, const bool add, const cv::Mat &maskedImage)
{
    if (!imgSrc.data) return false;
    if (polygon.size()==0) return false;    
    // fix bug SUZUKADECO-362
    if (m_index<=0){
        if(add==false);
//            return true; // fix reopen SUZUKADECO-306
        else{
            if(m_bSetRefColor){
                m_bSetRefColor = false;
            } else {
                referenceColor = -300;
            }
        }
    }
    // end fix bug
    
	cv::Mat img = imgSrc;
    int lineSize=toolSize;

	cv::Mat mask = cv::Mat::zeros(img.size(), CV_8UC1);
    
    if (lineSize<1) lineSize =1;
    else if (lineSize>255) lineSize = 255;
    
#if CMASK_RESIZE
    lineSize=(toolSize+1)/2.0;
    cv::line(mask, cv::Point(polygon[0].x/2, polygon[0].y/2), cv::Point(polygon[0].x/2, polygon[0].y/2), CV_RGB(255,255,255), lineSize);
    for(int i=1; i<polygon.size(); i++)
    {
        cv::line(mask, cv::Point(polygon[i-1].x/2, polygon[i-1].y/2), cv::Point(polygon[i].x/2, polygon[i].y/2), CV_RGB(255,255,255), lineSize);
    }
#else
    cv::line(mask, polygon[0], polygon[0], CV_RGB(255,255,255), lineSize);
    for(int i=1; i<polygon.size(); i++)
    {
        cv::line(mask, polygon[i-1], polygon[i], CV_RGB(255,255,255), lineSize);
    }    
#endif
    
    // fix 522
    if (add) {
        removeMaskedRegion(mask,maskedImage);
    }
    
    addMask(mask, add);
    img.release();
    mask.release();
    return true;
}


bool CMask::eraseMaskByImage(const cv::Mat &imgSrc, const cv::Mat &mask)
{
    if (imgSrc.size()!=mask.size())
    {
        //std::cout << "imgSrcSize = " << imgSrc.size() << std::endl;
        //std::cout << "maskSize = " << mask.size() << std::endl;
        //std::cout << "mask channel = " << mask.channels() << std::endl;
        return false;
    }    
    cv::Mat m;
    cv::cvtColor(mask, m, CV_BGRA2GRAY);
    addMask(mask, false);
    m.release();
    return true;
}

/// <summary>
/// Undoes this instance.
/// </summary>
/// <returns>bool.</returns>
bool CMask::undo()
{
    m_imgDst.release();
    m_index --;
    if (m_index <= 0){
        m_index = 0;
        return false;
    }
    return true;
}

/// <summary>
/// Redoes this instance.
/// </summary>
/// <returns>bool.</returns>
bool CMask::redo()
{
    m_imgDst.release();
    m_index ++;
    if (m_index>=m_imgMaskList.size()-1)
    {
        m_index=m_imgMaskList.size()-1;
        return false;
    }
    return true;
}

/// <summary>
/// Removes the last undo.
/// </summary>
void CMask::removeLastUndo()
{
    if (m_imgMaskList.size()>1)
    {
        m_imgMaskList[0].release();
        m_imgMaskList.erase (m_imgMaskList.begin());
        m_index --;
        //std::cout << "remove last undo =" << m_index << std::endl;
    }
}

//
void CMask::clearCache(){
    m_imgDst.release();
}

