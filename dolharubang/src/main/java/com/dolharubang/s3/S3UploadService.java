package com.dolharubang.s3;

import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.AmazonS3Exception;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Set;
import javax.imageio.ImageIO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.coobird.thumbnailator.Thumbnails;
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

    // 허용 확장자 목록
    private static final Set<String> ALLOWED_EXTENSIONS = Set.of("jpg", "jpeg", "png", "gif", "bmp",
        "svg");

    public void validateImageFile(MultipartFile file) {
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || originalFilename.lastIndexOf(".") == -1) {
            throw new CustomException(ErrorCode.NOT_IMAGE_FILE, "이미지 파일이 아닙니다.");
        }
        String ext = originalFilename.substring(originalFilename.lastIndexOf(".") + 1)
            .toLowerCase();
        if (!ALLOWED_EXTENSIONS.contains(ext)) {
            throw new CustomException(ErrorCode.NOT_IMAGE_FILE, "이미지 파일이 아닙니다.");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new CustomException(ErrorCode.NOT_IMAGE_FILE, "이미지 파일이 아닙니다.");
        }
    }

    public String saveImage(MultipartFile file, String dirName, Long id) {
        if (file == null || file.isEmpty()) {
            throw new CustomException(ErrorCode.FILE_UPLOAD_FAILED, "파일이 비어있습니다.");
        }

        validateImageFile(file);

        try {
            String originalFilename = file.getOriginalFilename();
            String ext = originalFilename.substring(originalFilename.lastIndexOf("."))
                .toLowerCase();
            String fileName = dirName + id + ext;

            // 이미지 압축 처리 (JPEG 예시, 품질 0.7)
            ByteArrayOutputStream os = new ByteArrayOutputStream();
            BufferedImage image = ImageIO.read(file.getInputStream());

            if (".jpg".equals(ext) || ".jpeg".equals(ext)) {
                // JPEG 압축
                Thumbnails.of(image)
                    .scale(1.0)
                    .outputQuality(0.7) // 70% 품질
                    .outputFormat("jpg")
                    .toOutputStream(os);
            } else if (".png".equals(ext)) {
                // PNG는 무손실이지만, 크기 줄이기 위해 리사이즈
                Thumbnails.of(image)
                    .scale(1.0)
                    .outputFormat("png")
                    .toOutputStream(os);
            } else {
                // 기타 포맷은 원본 업로드
                file.getInputStream().transferTo(os);
            }

            byte[] compressedBytes = os.toByteArray();
            ByteArrayInputStream compressedInputStream = new ByteArrayInputStream(compressedBytes);

            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentLength(compressedBytes.length);
            metadata.setContentType(file.getContentType());

            amazonS3Client.putObject(bucket, fileName, compressedInputStream, metadata);

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
