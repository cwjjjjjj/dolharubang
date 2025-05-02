package com.dolharubang.s3;

import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.AmazonS3Exception;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@Service
@RequiredArgsConstructor
public class S3UploadService {

    private final AmazonS3Client amazonS3Client;

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    public String saveImage(MultipartFile file, String dirName, Long id) {
        if (file == null || file.isEmpty()) {
            throw new CustomException(ErrorCode.FILE_UPLOAD_FAILED, "파일이 비어있습니다.");
        }

        try {
            String originalFilename = file.getOriginalFilename();
            String ext = originalFilename.substring(originalFilename.lastIndexOf("."));
            String fileName = dirName + id + ext;

            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentLength(file.getSize());
            metadata.setContentType(file.getContentType());

            // S3에 파일 업로드
            amazonS3Client.putObject(bucket, fileName, file.getInputStream(), metadata);

            // 업로드된 파일 URL 반환
            return amazonS3Client.getUrl(bucket, fileName).toString();
        } catch (AmazonS3Exception e) {
            log.error("S3 업로드 실패: {}", e.getMessage(), e);
            throw new CustomException(ErrorCode.FILE_UPLOAD_FAILED, "S3 업로드 실패: " + e.getMessage());
        } catch (IOException e) {
            log.error("파일 업로드 I/O 오류: {}", e.getMessage(), e);
            throw new CustomException(ErrorCode.FILE_UPLOAD_FAILED, "파일 업로드 실패");
        }
    }

    public void deleteImage(String imgUrl, String filePath) {
        try {
            // URL에서 마지막 부분을 추출하여 keyName을 생성
            String[] parts = imgUrl.split("/");
            String keyName = filePath + parts[parts.length - 1];

            // S3 버킷에서 해당 객체 존재 여부 확인
            boolean isObjectExist = amazonS3Client.doesObjectExist(bucket, keyName);
            if (isObjectExist) {
                amazonS3Client.deleteObject(bucket, keyName);
            } else {
                throw new CustomException(ErrorCode.MEMBER_PROFILE_IMAGE_NOT_FOUND);
            }
        } catch (Exception e) {
            log.debug("Delete File failed", e);
        }
    }

    /*
    기존 프로필 이미지 없어도 (=기본 프로필이라도) 오류 터지지 않게 간소화한 메서드
     */
    public void deleteImageIfExist(String imgUrl, String filePath) {

        // URL에서 마지막 부분을 추출하여 keyName을 생성
        String[] parts = imgUrl.split("/");
        String keyName = filePath + parts[parts.length - 1];

        // S3 버킷에서 해당 객체 존재 여부 확인
        boolean isObjectExist = amazonS3Client.doesObjectExist(bucket, keyName);
        if (isObjectExist) {
            amazonS3Client.deleteObject(bucket, keyName);
        }
    }
}
