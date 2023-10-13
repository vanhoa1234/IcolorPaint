// ***********************************************************************
// Assembly         : Decorator
// Author           : HuanVB
// Created          : 09-09-2013
//
// Last Modified By : HuanVB
// Last Modified On : 09-25-2013
// ***********************************************************************
// <copyright file="Mask.h" company="">
//     Copyright (c) . All rights reserved.
// </copyright>
// <summary></summary>
// ***********************************************************************


#pragma once
#include <opencv2/opencv.hpp>

#define DEVELOPMENT 0
#define CMASK_RESIZE 0

/// <summary>
/// Class CMask
/// </summary>
class CMask
{
public:
	// constructor function
	CMask(void);
    CMask(const int r, const int g, const int b);
	// de-constructor function
	~CMask(void);
public:
    // get current mask
    const cv::Mat getCurrentMask();
    // add mask by image
    bool iniMaskByImagePath(const std::string pathFile);
	// add mask by auto mode
	bool addMaskBySeed(const cv::Mat &imgSrc, const cv::Mat &imgResizedSrc, const cv::Point seedPt, const bool limitedEdge, const cv::Mat &maskedImage);
    // modify current mask
    bool modifyMaskBySeed(const cv::Mat &imgSrc, const cv::Mat &imgResizedSrc, const cv::Point seedPt, const bool limitedEdge, const cv::Mat &maskedImage);
	// add/erase mask by manual mode
	bool addMaskByPolygon(const cv::Mat &imgSrc, const std::vector<cv::Point> &polygon, const bool add=true);
    //
    bool addMaskByPoints(const cv::Mat &imgSrc, const std::vector<cv::Point> &points, const bool add, const cv::Mat &maskedImage);
    //
    bool modifyMaskByPoints(const cv::Mat &imgSrc, const std::vector<cv::Point> &points);
    //
    bool eraseMaskByPolygon(const cv::Mat &imgSrc, const std::vector<cv::Point> &polygon, const int toolSize, const bool add, const cv::Mat &maskedImage);
    //
    bool eraseMaskByImage(const cv::Mat &imgSrc, const cv::Mat &mask);
	// paint image with mask
	void Paint(const cv::Mat &imgSrc, cv::Mat &imgDst);
	// set color to painting
	void setColor(const int r, const int g, const int b);
	// set pattern image
	void setColor(const cv::Mat &imgPattern);
	// set tolerance for auto mode
	void setTolerance(const int tol);
    // set mask to be non painting
    void setNonePainting(const bool np);
    // get mask to be non painting
    bool getNonePainting();
    // return false if begin
    bool undo();
    // return false if end
    bool redo();
    //
    void removeLastUndo();
    
    //
    void clearCache();
    
    //
    void setHighLight(const bool hl);
    void getHighLightRegion(std::vector<std::vector<cv::Point>> &region);
    void drawHighLight(cv::Mat &dst);
    
    void setReferenceColor(const int color);
    int getReferenceColor();
    
    void setDefaultColor(const bool def);
private:
    bool m_bSetRefColor;
	bool m_bDefaultColor;
private:
    void highLight(const cv::Mat &mask, cv::Mat &imgDst);
    bool findDynamicRange(const cv::Mat &imgSrc, const cv::Mat &mask, int &minValue, int &maxValue);
    
    // compress dynamic range
    void compressDynamicRange(cv::Mat &image, const int replace, const int reference, const cv::Mat &mask);
    //
    bool modifyMask(const cv::Mat &mask);
    //
    bool creatMaskByPolygon(cv::Mat &mask, const std::vector<cv::Point> &polygon);
    //
    bool createMaskBySeed(const cv::Mat &imgSrc, const cv::Mat &imgResizedSrc, cv::Mat &maskDst, const cv::Point seedPt, const bool limitedEdge);
	//
	void calculateEdge(const cv::Mat &imgSrc, cv::Mat &edge);
	// 
	void removeEdgeOnSeedPoint(cv::Mat &edge, const cv::Point seedPt);
	// 
	void limiteMaskUsingEdge(const cv::Mat &imgSrc, cv::Mat &mask, const cv::Point seedPt);
    //
    void refinePolygon(const cv::Mat &imgSrc, const std::vector<cv::Point> &polySrc, std::vector<cv::Point> &polyDes);
    //
    void smoothBorder(cv::Mat &src);
    //
    void eraseMask(const cv::Mat &src, cv::Mat &dst);
    //
    void removeRedo();
	// add/erase a mask
	void addMask(const cv::Mat &mask, const bool add=true);
    // draw pattern on image with mask
    void drawPattern(const cv::Mat &imgSrc, cv::Mat &imgDst, const cv::Mat &pattern, const cv::Mat &mask);
    // remove small hole in mask area
    void removeHole(cv::Mat &img);
    void removeSmallEdge(cv::Mat &edge);
	// replace color image by another color using mask
	void replaceColor(const cv::Mat &imgSrc, cv::Mat &imgDst, const cv::Scalar newColor, const cv::Mat &mask);
	// calculate value of pixel that appear at most mask
	int calculateColorInMask(const cv::Mat &imgSrc, const cv::Mat &mask);
    
    //
    bool removeMaskedRegion(cv::Mat &mask, const cv::Mat &maskedImage);
	// mask list
	/// <summary>
	/// The m_img mask list
	/// </summary>
	std::vector<cv::Mat> m_imgMaskList;
    // cached image for show
    cv::Mat m_imgDst;
    // index of mask
	/// <summary>
	/// The m_index
	/// </summary>
	int m_index;
	// new color
	/// <summary>
	/// The color  
	/// </summary>
	cv::Scalar m_scColor;
	// pattern
	/// <summary>
	/// The m_img pattern
	/// </summary>
	cv::Mat m_imgPattern;
    // no painting status
	/// <summary>
	/// The m_none painting
	/// </summary>
	bool m_nonePainting;
	// tolerance for auto mode
	/// <summary>
	/// The M_N tolerance
	/// </summary>
	int m_nTolerance;
    
    bool m_bHighLight;
    
    int referenceColor;
#if DEVELOPMENT
	// newest seed point
	/// <summary>
	/// The M_PT current
	/// </summary>
	cv::Point m_ptCurrent;
#endif
};

