/*M///////////////////////////////////////////////////////////////////////////////////////
//
//  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.
//
//  By downloading, copying, installing or using the software you agree to this license.
//  If you do not agree to this license, do not download, install,
//  copy or use the software.
//
//
//                           License Agreement
//                For Open Source Computer Vision Library
//
// Copyright (C) 2000-2008, Intel Corporation, all rights reserved.
// Copyright (C) 2008-2012, Willow Garage Inc., all rights reserved.
// Third party copyrights are property of their respective owners.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//   * Redistribution's of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//   * Redistribution's in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//   * The name of the copyright holders may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
// This software is provided by the copyright holders and contributors "as is" and
// any express or implied warranties, including, but not limited to, the implied
// warranties of merchantability and fitness for a particular purpose are disclaimed.
// In no event shall the Intel Corporation or contributors be liable for any direct,
// indirect, incidental, special, exemplary, or consequential damages
// (including, but not limited to, procurement of substitute goods or services;
// loss of use, data, or profits; or business interruption) however caused
// and on any theory of liability, whether in contract, strict liability,
// or tort (including negligence or otherwise) arising in any way out of
// the use of this software, even if advised of the possibility of such damage.
//
//M*/

#include "inpainter.h"

static bool volatile g_stop = false;

Inpainter::Inpainter(){
    
}

Inpainter::Inpainter(cv::Mat inputImage,cv::Mat mask,int halfPatchWidth,int mode){
    g_stop = false;
    this->inputImage=inputImage.clone();
    this->mask=mask.clone();
    this->updatedMask=mask.clone();
    this->workImage=inputImage.clone();
    this->result.create(inputImage.size(),inputImage.type());
    this->mode=mode;
    this->halfPatchWidth=halfPatchWidth;
}

int Inpainter::checkValidInputs(){
    if(this->inputImage.type()!=CV_8UC3)
        return ERROR_INPUT_MAT_INVALID_TYPE;
    if(this->mask.type()!=CV_8UC1)
        return ERROR_INPUT_MASK_INVALID_TYPE;
    if(!CV_ARE_SIZES_EQ(&mask,&inputImage))
        return ERROR_MASK_INPUT_SIZE_MISMATCH;
    if(halfPatchWidth==0)
        return ERROR_HALF_PATCH_WIDTH_ZERO;
    return CHECK_VALID;
}

void Inpainter::stop(bool stop){
    g_stop = stop;
}

/**
 *
 * @param image
 * @return
 */
/*
cv::Mat convertTo8U(const cv::Mat &image)
{
	double m,M;
	cv::minMaxLoc(image,&m,&M);
	cv::Mat image1(image.size(),CV_8UC1);	
	image.convertTo(image1,CV_8U, 255.0/(M-m), -m*255.0/(M-m));
	return image1;
}

static cv::VideoWriter outputVideo;
cv::Mat combineImage(const cv::Mat &mask, const cv::Mat &gx, const cv::Mat &gy, const cv::Mat &img) {
	cv::Mat maskRGB, gxRGB, gyRGB;
	cv::cvtColor(mask, maskRGB, cv::COLOR_GRAY2RGB);
	gxRGB = convertTo8U(gx);
	gyRGB = convertTo8U(gy);
	cv::cvtColor(gxRGB, gxRGB, cv::COLOR_GRAY2RGB);
	cv::cvtColor(gyRGB, gyRGB, cv::COLOR_GRAY2RGB);

	cv::Mat combineImg = cv::Mat::zeros(cv::Size(2*img.cols, 2*img.rows), img.type());
	gxRGB.copyTo(combineImg(cv::Rect(0, 0, img.cols, img.rows)));
	gyRGB.copyTo(combineImg(cv::Rect(img.cols, 0, img.cols, img.rows)));
	maskRGB.copyTo(combineImg(cv::Rect(0, img.rows, img.cols, img.rows)));
	img.copyTo(combineImg(cv::Rect(img.cols, img.rows, img.cols, img.rows)));

	return combineImg;
}

void writeVideo(const cv::Mat &img){
 
	std::cout  << "Write video file." << std::endl;
	if (!outputVideo.isOpened())
		outputVideo.open("C:/Images/inpainting.avi", -1, 25, img.size(), true);

    if (!outputVideo.isOpened())
    {
        std::cout  << "Could not open the output video for write: " << std::endl;
        return;
    }
	 outputVideo << img;
}
*/
void Inpainter::inpaint(){
    initializeMats();
    calculateGradients();
    bool stay=true;
    while(stay){
        if (g_stop) break;
        
        computeFillFront();
        computeConfidence();
        computeData();
        computeTarget();
        computeBestPatch();
        
        if (g_stop) break;

        updateMats();
        stay=checkEnd();
		
//		writeVideo(combineImage(updatedMask, gradientX, gradientY, workImage));
//      cv::imshow("inpaint",workImage);
//      cv::waitKey(2);
    }
    if (g_stop) result = inputImage.clone();
    else    result=workImage.clone();
    g_stop = false;
}

void Inpainter::calculateGradients(){
    cv::Mat srcGray;
    cv::cvtColor(workImage,srcGray,CV_BGR2GRAY);

    cv::Scharr(srcGray,gradientX,CV_16S,1,0);
    cv::convertScaleAbs(gradientX,gradientX);
    gradientX.convertTo(gradientX,CV_32F);

    cv::Scharr(srcGray,gradientY,CV_16S,0,1);
    cv::convertScaleAbs(gradientY,gradientY);
    gradientY.convertTo(gradientY,CV_32F);

    for(int x=0;x<sourceRegion.cols;x++){
        for(int y=0;y<sourceRegion.rows;y++){

            if(sourceRegion.at<uchar>(y,x)==0){
                gradientX.at<float>(y,x)=0;
                gradientY.at<float>(y,x)=0;
            }/*else
            {
                if(gradientX.at<float>(y,x)<255)
                    gradientX.at<float>(y,x)=0;
                if(gradientY.at<float>(y,x)<255)
                    gradientY.at<float>(y,x)=0;
            }*/

        }
    }
    gradientX/=255;
    gradientY/=255;
}

void Inpainter::initializeMats(){
    cv::threshold(this->mask,this->confidence,10,255,CV_THRESH_BINARY);
    cv::threshold(confidence,confidence,2,1,CV_THRESH_BINARY_INV);
    confidence.convertTo(confidence,CV_32F);

    this->sourceRegion=confidence.clone();
    this->sourceRegion.convertTo(sourceRegion,CV_8U);
    this->originalSourceRegion=sourceRegion.clone();

    cv::threshold(mask,this->targetRegion,10,255,CV_THRESH_BINARY);
    cv::threshold(targetRegion,targetRegion,2,1,CV_THRESH_BINARY);
    targetRegion.convertTo(targetRegion,CV_8U);
    data=cv::Mat(inputImage.rows,inputImage.cols,CV_32F,cv::Scalar::all(0));


    LAPLACIAN_KERNEL=cv::Mat::ones(3,3,CV_32F);
    LAPLACIAN_KERNEL.at<float>(1,1)=-8;
    NORMAL_KERNELX=cv::Mat::zeros(3,3,CV_32F);
    NORMAL_KERNELX.at<float>(1,0)=-1;
    NORMAL_KERNELX.at<float>(1,2)=1;
    cv::transpose(NORMAL_KERNELX,NORMAL_KERNELY);

	for (int i=0; i<512; i++) luts[i] = i*i;


}
void Inpainter::computeFillFront(){

    cv::Mat sourceGradientX,sourceGradientY,boundryMat;
	cv::Laplacian(targetRegion,boundryMat,CV_16S);
	cv::Sobel(sourceRegion,sourceGradientX,CV_16S, 1, 0);
	cv::Sobel(sourceRegion,sourceGradientY,CV_16S, 0, 1);

//    cv::filter2D(targetRegion,boundryMat,CV_16S,LAPLACIAN_KERNEL);
//    cv::filter2D(sourceRegion,sourceGradientX,CV_16S,NORMAL_KERNELX);
//    cv::filter2D(sourceRegion,sourceGradientY,CV_16S,NORMAL_KERNELY);
    
    boundryMat.convertTo(boundryMat,CV_32F);
    sourceGradientX.convertTo(sourceGradientX,CV_32F);
    sourceGradientY.convertTo(sourceGradientY,CV_32F);
    
    fillFront.clear();
    normals.clear();

    for(int y=0;y<boundryMat.rows;y++){
		const float* bin_ptr = boundryMat.ptr<float>(y);
		const float* X_ptr = sourceGradientX.ptr<float>(y);
		const float* Y_ptr = sourceGradientY.ptr<float>(y);
        for(int x=0;x<boundryMat.cols;x++){
            if(bin_ptr[x]>0){
                fillFront.push_back(cv::Point2i(x,y));
                float dx=X_ptr[x];
                float dy=Y_ptr[x];
                cv::Point2f normal(dy,-dx);
                float tempF=std::sqrt((normal.x*normal.x)+(normal.y*normal.y));
                if(tempF!=0){
					normal.x=normal.x/tempF;
					normal.y=normal.y/tempF;
                }
                normals.push_back(normal);
            }
        }
    }

}

void Inpainter::computeConfidence(){
    cv::Point2i a,b;
    for(int i=0;i<fillFront.size();i++){
        cv::Point2i currentPoint=fillFront.at(i);
        getPatch(currentPoint,a,b);
        float total=0;
        for(int y=a.y;y<=b.y;y++){
			const uchar* targetRegion_ptr = targetRegion.ptr(y);
			const float* confidence_ptr = confidence.ptr<float>(y);
            for(int x=a.x;x<=b.x;x++){
                if(targetRegion_ptr[x]==0){
                    total+=confidence_ptr[x];
                }
            }
        }
        confidence.at<float>(currentPoint.y,currentPoint.x)=total/((b.x-a.x+1)*(b.y-a.y+1));
    }
}

void Inpainter::computeData(){

    for(int i=0;i<fillFront.size();i++){
        cv::Point2i currentPoint=fillFront.at(i);
        cv::Point2i currentNormal=normals.at(i);
        data.at<float>(currentPoint.y,currentPoint.x)=
			std::fabs(gradientX.at<float>(currentPoint.y,currentPoint.x)*currentNormal.x+
			gradientY.at<float>(currentPoint.y,currentPoint.x)*currentNormal.y)+.001;
    }
}

void Inpainter::computeTarget(){

    targetIndex=0;
    float maxPriority=0;
    float priority=0;
    cv::Point2i currentPoint;
    for(int i=0;i<fillFront.size();i++){
        currentPoint=fillFront.at(i);
        priority=data.at<float>(currentPoint.y,currentPoint.x)*confidence.at<float>(currentPoint.y,currentPoint.x);
        if(priority>maxPriority){
            maxPriority=priority;
            targetIndex=i;
        }
    }
	 
}

void Inpainter::computeBestPatch(){
    double minError=9999999999999999,bestPatchVarience=9999999999999999;
    cv::Point2i a,b;
    cv::Point2i currentPoint=fillFront.at(targetIndex);
    cv::Vec3b sourcePixel,targetPixel;
    double meanR,meanG,meanB;
    double difference, patchError;
    bool skipPatch;
    getPatch(currentPoint,a,b);
    int width=b.x-a.x+1;
    int height=b.y-a.y+1;
	int const window = 5;

//	for(int y=0;y<=workImage.rows-height;y++){
//		for(int x=0;x<=workImage.cols-width;x++){

	for(int y=MAX(0, currentPoint.y-window*height); y<MIN(currentPoint.y+window*height, workImage.rows-height);y++){
		for(int x=MAX(0, currentPoint.x-window*width); x<MIN(currentPoint.x+window*width, workImage.cols-width);x++){
            
            if (g_stop) return;
            
            patchError=0;
            meanR=0;meanG=0;meanB=0;
            skipPatch=false;
            for(int y2=0;y2<height;y2++){
				const uchar* originalSourceRegion_ptr = originalSourceRegion.ptr(y+y2);
				const uchar* sourceRegion_ptr = sourceRegion.ptr(a.y+y2);
				const cv::Vec3b* sourcePixel_ptr = workImage.ptr<cv::Vec3b>(y+y2);
				const cv::Vec3b* targetPixel_ptr = workImage.ptr<cv::Vec3b>(a.y+y2);
                for(int x2=0;x2<width;x2++){
                    if(originalSourceRegion_ptr[x+x2]==0){
                        skipPatch=true;
                        break;
                     }

                    if(sourceRegion_ptr[a.x+x2]==0)
                        continue;

                    sourcePixel=sourcePixel_ptr[x+x2];
                    targetPixel=targetPixel_ptr[a.x+x2];


					patchError+= luts[abs(sourcePixel[0]-targetPixel[0])]+
						luts[abs(sourcePixel[1]-targetPixel[1])]+
						luts[abs(sourcePixel[2]-targetPixel[2])];

					/*for(int i=0;i<3;i++){
                        difference=sourcePixel[i]-targetPixel[i];
                        patchError+=difference*difference;
                    }
					*/
                    meanB+=sourcePixel[0];meanG+=sourcePixel[1];meanR+=sourcePixel[2];
                }
                if(skipPatch)
                    break;
            }

            if(skipPatch)
                continue;

            if(patchError<minError){
                minError=patchError;
                bestMatchUpperLeft=cv::Point2i(x,y);
                bestMatchLowerRight=cv::Point2i(x+width-1,y+height-1);

                double patchVarience=0;

                for(int y2=0;y2<height;y2++){
					const uchar* sourceRegion_ptr = sourceRegion.ptr(a.y+y2);
					const cv::Vec3b* sourcePixel_ptr = workImage.ptr<cv::Vec3b>(y+y2);
                    for(int x2=0;x2<width;x2++){
                        if(sourceRegion_ptr[a.x+x2]==0){
                            sourcePixel=sourcePixel_ptr[x+x2];
                            difference=sourcePixel[0]-meanB;
                            patchVarience+=difference*difference;
                            difference=sourcePixel[1]-meanG;
                            patchVarience+=difference*difference;
                            difference=sourcePixel[2]-meanR;
                            patchVarience+=difference*difference;
                        }

                    }
                }

				bestPatchVarience=patchVarience;

            }else if(patchError==minError){
                double patchVarience=0;
                for(int y2=0;y2<height;y2++){
					const uchar* sourceRegion_ptr = sourceRegion.ptr(a.y+y2);
					const cv::Vec3b* sourcePixel_ptr = workImage.ptr<cv::Vec3b>(y+y2);
                    for(int x2=0;x2<width;x2++){
                        if(sourceRegion_ptr[a.x+x2]==0){
                            sourcePixel=sourcePixel_ptr[x+x2];
                            difference=sourcePixel[0]-meanB;
                            patchVarience+=difference*difference;
                            difference=sourcePixel[1]-meanG;
                            patchVarience+=difference*difference;
                            difference=sourcePixel[2]-meanR;
                            patchVarience+=difference*difference;
                        }

                    }
                }

                if(patchVarience<bestPatchVarience){
                    minError=patchError;
                    bestMatchUpperLeft=cv::Point2i(x,y);
                    bestMatchLowerRight=cv::Point2i(x+width-1,y+height-1);
                    bestPatchVarience=patchVarience;
                }
            }
    }
    }
}

/*
void Inpainter::updateMats(){
    cv::Point2i targetPoint=fillFront.at(targetIndex);
    cv::Point2i a,b;
    getPatch(targetPoint,a,b);
    int width=b.x-a.x+1;
    int height=b.y-a.y+1;

    for(int x=0;x<width;x++){
        for(int y=0;y<height;y++){
            if(sourceRegion.at<uchar>(a.y+y,a.x+x)==0){

                workImage.at<cv::Vec3b>(a.y+y,a.x+x)=workImage.at<cv::Vec3b>(bestMatchUpperLeft.y+y,bestMatchUpperLeft.x+x);
                gradientX.at<float>(a.y+y,a.x+x)=gradientX.at<float>(bestMatchUpperLeft.y+y,bestMatchUpperLeft.x+x);
                gradientY.at<float>(a.y+y,a.x+x)=gradientY.at<float>(bestMatchUpperLeft.y+y,bestMatchUpperLeft.x+x);
                confidence.at<float>(a.y+y,a.x+x)=confidence.at<float>(targetPoint.y,targetPoint.x);
                sourceRegion.at<uchar>(a.y+y,a.x+x)=1;
                targetRegion.at<uchar>(a.y+y,a.x+x)=0;
                updatedMask.at<uchar>(a.y+y,a.x+x)=0;
            }
        }
    }


}
*/

void Inpainter::updateMats(){
    cv::Point2i targetPoint=fillFront.at(targetIndex);
    cv::Point2i a,b;
    getPatch(targetPoint,a,b);
    int width=b.x-a.x+1;
    int height=b.y-a.y+1;

    for(int y=0;y<height;y++){
		uchar* sourceRegion_ptr = sourceRegion.ptr(a.y+y);

		uchar* targetRegion_ptr = targetRegion.ptr(a.y+y);
        uchar* updatedMask_ptr = updatedMask.ptr(a.y+y);

		cv::Vec3b*  targetPixel_ptr = workImage.ptr<cv::Vec3b>(a.y+y);		
		const cv::Vec3b* sourcePixel_ptr = workImage.ptr<cv::Vec3b>(bestMatchUpperLeft.y+y);

		float* targerGradientX_ptr = gradientX.ptr<float>(a.y+y);
		const float* sourceGradientX_ptr = gradientX.ptr<float>(bestMatchUpperLeft.y+y);

		float* targerGradientY_ptr = gradientY.ptr<float>(a.y+y);
		const float* sourceGradientY_ptr = gradientY.ptr<float>(bestMatchUpperLeft.y+y);

		float* targerConfidence_ptr = confidence.ptr<float>(a.y+y);
		const float* sourceConfidence_ptr = confidence.ptr<float>(targetPoint.y);

		for(int x=0;x<width;x++){
            if(sourceRegion_ptr[a.x+x]==0){
                targetPixel_ptr[a.x+x] = sourcePixel_ptr[bestMatchUpperLeft.x+x];
                targerGradientX_ptr[a.x+x]=sourceGradientX_ptr[bestMatchUpperLeft.x+x];
				targerGradientY_ptr[a.x+x]=sourceGradientY_ptr[bestMatchUpperLeft.x+x];
                targerConfidence_ptr[a.x+x]=sourceConfidence_ptr[targetPoint.x];

                sourceRegion_ptr[a.x+x]=1;
                targetRegion_ptr[a.x+x]=0;
                updatedMask_ptr[a.x+x]=0;
            }
        }
    }
}

bool Inpainter::checkEnd(){
    
    if (cv::countNonZero(sourceRegion) == sourceRegion.cols*sourceRegion.rows)
        return false;
    else
        return true;
}

void Inpainter::getPatch(cv::Point2i &centerPixel, cv::Point2i &upperLeft, cv::Point2i &lowerRight){
    int x,y;
    x=centerPixel.x;
    y=centerPixel.y;

    int minX=std::max(x-halfPatchWidth,0);
    int maxX=std::min(x+halfPatchWidth,workImage.cols-1);
    int minY=std::max(y-halfPatchWidth,0);
    int maxY=std::min(y+halfPatchWidth,workImage.rows-1);


    upperLeft.x=minX;
    upperLeft.y=minY;

    lowerRight.x=maxX;
    lowerRight.y=maxY;
}
