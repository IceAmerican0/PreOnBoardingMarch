//
//  ViewController.swift
//  PreOnBoardingMarch
//
//  Created by 박성준 on 2023/02/23.
//

import UIKit
import Then
import SnapKit

fileprivate enum ImageURL {
    private static let imageIds: [String] = [
        "europe-4k-1369012",
        "europe-4k-1318341",
        "europe-4k-1379801",
        "cool-lion-167408",
        "iron-man-323408"
    ]
    
    static subscript(index: Int) -> URL {
        let id = imageIds[index]
        return URL(string: "https://wallpaperaccess.com/download/"+id)!
    }
}


final class ViewController: UIViewController {
    
    private let whiteColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private let blueColor = #colorLiteral(red: 0, green: 0.4780646563, blue: 0.9985368848, alpha: 1)
    
    let imageUrls = ["https://mblogthumb-phinf.pstatic.net/MjAxODA2MThfMjc0/MDAxNTI5MjgwNDQwMTk2.xv-JyGtGew6QFe_DY0OHFRJq302SJat2WTrnBj5TXMkg.CO1gbFTvlsz-UaCvkECQqbp6-2BdH_mp_CE84enAMEEg.JPEG.michael127/c038302b74b648044c64eab41547e8258bada22739e5ff1936043c09fb9a1cb217169db9149b4255f349b243371fec45a12a3f029b5cd6d2efa79605343c745829d1eb240d8802899fc7bd4782d5c8.jpg?type=w800","https://i.ytimg.com/vi/zxcEi7vX_vA/maxresdefault.jpg","https://post-phinf.pstatic.net/MjAyMTAxMDdfMTE4/MDAxNjA5OTUxNzc5MDQ1.6P6ZoVjN3Xo9MKdD6NUBsRA-ZW7K3DTjTCpFTe3V2Vcg.p0kCAuPq-J2LFy5J-LW15NZnBCKDPDNkkSKMmcNiVt8g.JPEG/4fbd7361c5f433aaf79f7c1e1299b61a.jpg?type=w1200","https://t1.daumcdn.net/cfile/tistory/146A56344E33BA721B","https://img1.daumcdn.net/thumb/R658x0.q70/?fname=https://t1.daumcdn.net/news/202105/25/hero_nitko/20210525035006261hsvw.jpg"]
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var loadButton: UIButton!
    private var observation: NSKeyValueObservation!
    private var task: URLSessionDataTask!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadButton.setTitle("Stop", for: .selected)
        loadButton.setTitle("Load", for: .normal)
        loadButton.isSelected = false
    }
    
    deinit {
        observation.invalidate()
        observation = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildLayout()
    }
    
    func reset() {
        imageView.image = .init(systemName: "photo")
        progressView.progress = 0
        loadButton.isSelected = false
    }
    
    func loadImage() {
        loadButton.sendActions(for: .touchUpInside)
    }
    
    @IBAction private func touchUpLoadButton(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        guard sender.isSelected else {
            task.cancel()
            return
        }
        
        guard (0...4).contains(sender.tag) else {
            fatalError("버튼 태그를 확인해주세요")
        }
        let url = ImageURL[sender.tag]
        let request = URLRequest(url: url)
        
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                guard error.localizedDescription == "cancelled" else {
                    fatalError(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    self.reset()
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.imageView.image = .init(systemName: "xmark")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = image
                self.loadButton.isSelected = false
            }
        }
        
        observation = task.progress.observe(\.fractionCompleted,
                                             options: [.new],
                                             changeHandler: { progress, change in
            DispatchQueue.main.async {
                self.progressView.progress = Float(progress.fractionCompleted)
            }
        })
        
        task.resume()
    }
    
    private func buildLayout() {
        view.backgroundColor = whiteColor
        
        var verticalGap = 100
        
        for number in 0..<5 {

            let imageView = UIImageView().then {
                $0.image = UIImage(systemName: "photo")
                $0.contentMode = .scaleAspectFit
                $0.backgroundColor = whiteColor
                $0.tag = number
                view.addSubview($0)
                
                $0.snp.makeConstraints {
                    $0.size.equalTo(CGSize(width: 120, height: 80))
                    $0.top.equalTo(view).inset(verticalGap)
                    $0.leading.equalTo(view).inset(30)
                }
            }
            
            let _ = UIButton().then {
                $0.backgroundColor = blueColor
                $0.setTitle("Load", for: .normal)
                $0.setTitleColor(whiteColor, for: .normal)
                $0.layer.cornerRadius = 15
                $0.tag = number
                $0.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
                view.addSubview($0)
                
                $0.snp.makeConstraints {
                    $0.size.equalTo(CGSize(width: 70, height: 50))
                    $0.centerY.equalTo(imageView.snp.centerY)
                    $0.trailing.equalTo(view).inset(30)
                }
            }
            
            verticalGap += 120
        }
        
        let _ = UIButton().then {
            $0.backgroundColor = blueColor
            $0.setTitle("Load All Images", for: .normal)
            $0.setTitleColor(whiteColor, for: .normal)
            $0.layer.cornerRadius = 15
            $0.tag = 5
            $0.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            view.addSubview($0)
            
            $0.snp.makeConstraints {
                $0.height.equalTo(50)
                $0.bottom.leading.trailing.equalTo(view).inset(30)
            }
        }
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        let number = sender.tag
        reloadImage(image: UIImage(systemName: "photo")!, number: number)
        
        if number == 5 {
            for i in 0..<imageUrls.count {
                imageDownload(number: i)
            }
        } else {
            imageDownload(number: number)
        }
    }
    
    func imageDownload(number: Int) {
        guard let imageUrl = URL(string: imageUrls[number]) else { return }
        
        let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data, error == nil else { return }
            let image = UIImage(data: data)
            
            DispatchQueue.main.async {
                self.reloadImage(image: image!, number: number)
            }
        }
        task.resume()
    }
    
    func reloadImage(image: UIImage, number: Int) {
        if let imageView = self.view.subviews.first(where: {$0 is UIImageView && $0.tag == number}) as? UIImageView {
            imageView.image = image
        }
    }
    
}

